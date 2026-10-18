package com.notoo.app;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.print.PrintAttributes;
import android.print.PrintManager;
import android.provider.MediaStore;
import android.speech.tts.TextToSpeech;
import android.util.Base64;
import android.webkit.JavascriptInterface;
import android.webkit.JsPromptResult;
import android.webkit.JsResult;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.EditText;
import android.widget.Toast;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.Locale;

/**
 * Notoo — a thin native shell around the offline web app.
 *
 * A bare WebView is not a browser: file pickers, JS dialogs, downloads,
 * printing, the clipboard and speech all need native plumbing or they silently
 * do nothing. Everything the web app needs is wired up below and exposed to it
 * as window.NotooNative.
 */
public class MainActivity extends Activity {

    private static final int REQ_FILE = 1001;
    private static final int REQ_STORAGE = 1002;

    private WebView web;
    private ValueCallback<Uri[]> fileCallback;
    private String pendingBase64Name, pendingBase64Mime, pendingBase64Data;
    private TextToSpeech tts;
    private boolean ttsReady = false;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        web = new WebView(this);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setAllowFileAccess(true);
        s.setAllowContentAccess(true);
        s.setLoadWithOverviewMode(true);
        s.setUseWideViewPort(true);
        s.setBuiltInZoomControls(false);
        s.setDisplayZoomControls(false);
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setJavaScriptCanOpenWindowsAutomatically(true);
        // lets the page fetch the Google Fonts stylesheet from a file:// origin
        s.setAllowFileAccessFromFileURLs(true);
        s.setAllowUniversalAccessFromFileURLs(true);

        web.setWebViewClient(new WebViewClient());
        web.setWebChromeClient(new Chrome());
        web.addJavascriptInterface(new Bridge(), "NotooNative");
        web.setBackgroundColor(0xFFC99A5B);
        web.loadUrl("file:///android_asset/index.html");

        setContentView(web);

        tts = new TextToSpeech(this, status -> {
            ttsReady = (status == TextToSpeech.SUCCESS);
            if (ttsReady) {
                try { tts.setLanguage(Locale.getDefault()); } catch (Exception ignored) {}
            }
        });
    }

    // ------------------------------------------------------------------
    // Dialogs + file picker. Without these, prompt() returns null and
    // <input type="file"> never opens.
    // ------------------------------------------------------------------
    private class Chrome extends WebChromeClient {

        @Override
        public boolean onShowFileChooser(WebView v, ValueCallback<Uri[]> cb, FileChooserParams params) {
            if (fileCallback != null) fileCallback.onReceiveValue(null);
            fileCallback = cb;
            try {
                Intent intent = params.createIntent();
                intent.addCategory(Intent.CATEGORY_OPENABLE);
                startActivityForResult(intent, REQ_FILE);
                return true;
            } catch (Exception e) {
                fileCallback = null;
                toast("No file picker available");
                return false;
            }
        }

        @Override
        public boolean onJsAlert(WebView v, String url, String message, final JsResult r) {
            new AlertDialog.Builder(MainActivity.this)
                    .setMessage(message)
                    .setPositiveButton(android.R.string.ok, (d, w) -> r.confirm())
                    .setOnCancelListener(d -> r.cancel())
                    .show();
            return true;
        }

        @Override
        public boolean onJsConfirm(WebView v, String url, String message, final JsResult r) {
            new AlertDialog.Builder(MainActivity.this)
                    .setMessage(message)
                    .setPositiveButton(android.R.string.ok, (d, w) -> r.confirm())
                    .setNegativeButton(android.R.string.cancel, (d, w) -> r.cancel())
                    .setOnCancelListener(d -> r.cancel())
                    .show();
            return true;
        }

        @Override
        public boolean onJsPrompt(WebView v, String url, String message, String defaultValue,
                                  final JsPromptResult r) {
            final EditText input = new EditText(MainActivity.this);
            input.setSingleLine(true);
            if (defaultValue != null) input.setText(defaultValue);
            if (defaultValue != null) input.setSelection(input.getText().length());
            new AlertDialog.Builder(MainActivity.this)
                    .setMessage(message)
                    .setView(input)
                    .setPositiveButton(android.R.string.ok, (d, w) -> r.confirm(input.getText().toString()))
                    .setNegativeButton(android.R.string.cancel, (d, w) -> r.cancel())
                    .setOnCancelListener(d -> r.cancel())
                    .show();
            return true;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQ_FILE) {
            if (fileCallback == null) return;
            Uri[] results = null;
            if (resultCode == Activity.RESULT_OK && data != null) {
                if (data.getClipData() != null) {
                    int n = data.getClipData().getItemCount();
                    results = new Uri[n];
                    for (int i = 0; i < n; i++) results[i] = data.getClipData().getItemAt(i).getUri();
                } else if (data.getData() != null) {
                    results = new Uri[]{ data.getData() };
                }
            }
            fileCallback.onReceiveValue(results);
            fileCallback = null;
            return;
        }
        if (requestCode == REQ_STORAGE) {
            if (resultCode == Activity.RESULT_OK && pendingBase64Data != null) {
                writeBytes(pendingBase64Name, pendingBase64Mime, pendingBase64Data);
            } else {
                toast("Storage permission is needed to save files");
            }
            pendingBase64Name = pendingBase64Mime = pendingBase64Data = null;
            return;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onRequestPermissionsResult(int code, String[] perms, int[] results) {
        if (code == REQ_STORAGE) {
            if (results.length > 0 && results[0] == PackageManager.PERMISSION_GRANTED && pendingBase64Data != null) {
                writeBytes(pendingBase64Name, pendingBase64Mime, pendingBase64Data);
            } else {
                toast("Storage permission is needed to save files");
            }
            pendingBase64Name = pendingBase64Mime = pendingBase64Data = null;
        }
        super.onRequestPermissionsResult(code, perms, results);
    }

    // ------------------------------------------------------------------
    // The bridge the web app talks to.
    // ------------------------------------------------------------------
    private class Bridge {

        @JavascriptInterface
        public boolean available() { return true; }

        @JavascriptInterface
        public void saveBase64(final String name, final String mime, final String b64) {
            if (needsLegacyPermission()) {
                pendingBase64Name = name; pendingBase64Mime = mime; pendingBase64Data = b64;
                runOnUiThread(() -> requestPermissions(
                        new String[]{ Manifest.permission.WRITE_EXTERNAL_STORAGE }, REQ_STORAGE));
                return;
            }
            writeBytes(name, mime, b64);
        }

        @JavascriptInterface
        public void speak(final String text) {
            runOnUiThread(() -> {
                if (!ttsReady || tts == null) { toast("Speech engine is still starting"); return; }
                tts.stop();
                tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "notoo");
            });
        }

        @JavascriptInterface
        public void stopSpeak() {
            runOnUiThread(() -> { if (tts != null) tts.stop(); });
        }

        @JavascriptInterface
        public void shareText(final String subject, final String text) {
            runOnUiThread(() -> {
                try {
                    Intent i = new Intent(Intent.ACTION_SEND);
                    i.setType("text/plain");
                    i.putExtra(Intent.EXTRA_SUBJECT, subject);
                    i.putExtra(Intent.EXTRA_TEXT, text);
                    startActivity(Intent.createChooser(i, "Share note"));
                } catch (Exception e) { toast("Nothing to share to"); }
            });
        }

        @JavascriptInterface
        public void copy(final String text) {
            runOnUiThread(() -> {
                try {
                    ClipboardManager cm = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
                    cm.setPrimaryClip(ClipData.newPlainText("Notoo", text));
                    toast("Copied to clipboard");
                } catch (Exception e) { toast("Could not copy"); }
            });
        }

        @JavascriptInterface
        public void printPage() {
            runOnUiThread(() -> {
                try {
                    PrintManager pm = (PrintManager) getSystemService(Context.PRINT_SERVICE);
                    String job = "Notoo-" + System.currentTimeMillis();
                    pm.print(job, web.createPrintDocumentAdapter(job), new PrintAttributes.Builder().build());
                } catch (Exception e) { toast("Printing is not available"); }
            });
        }
    }

    // ------------------------------------------------------------------
    // helpers
    // ------------------------------------------------------------------
    private boolean needsLegacyPermission() {
        return Build.VERSION.SDK_INT < 29
                && checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED;
    }

    private void writeBytes(final String name, final String mime, final String b64) {
        runOnUiThread(() -> {
            try {
                byte[] bytes = Base64.decode(b64, Base64.DEFAULT);
                String where;
                if (Build.VERSION.SDK_INT >= 29) {
                    ContentValues cv = new ContentValues();
                    cv.put(MediaStore.Downloads.DISPLAY_NAME, name);
                    cv.put(MediaStore.Downloads.MIME_TYPE, mime);
                    Uri uri = getContentResolver().insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, cv);
                    if (uri == null) throw new Exception("MediaStore refused the file");
                    OutputStream os = getContentResolver().openOutputStream(uri);
                    if (os == null) throw new Exception("No output stream");
                    os.write(bytes); os.flush(); os.close();
                    where = "Downloads/" + name;
                } else {
                    File dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
                    if (dir == null || (!dir.exists() && !dir.mkdirs())) dir = getExternalFilesDir(null);
                    File f = new File(dir, name);
                    FileOutputStream fos = new FileOutputStream(f);
                    fos.write(bytes); fos.flush(); fos.close();
                    where = f.getAbsolutePath();
                }
                toast("Saved to " + where);
            } catch (Exception e) {
                toast("Could not save: " + e.getMessage());
            }
        });
    }

    private void toast(final String msg) {
        runOnUiThread(() -> Toast.makeText(MainActivity.this, msg, Toast.LENGTH_LONG).show());
    }

    @Override
    public void onBackPressed() {
        if (web != null && web.canGoBack()) web.goBack();
        else super.onBackPressed();
    }

    @Override
    protected void onDestroy() {
        if (tts != null) { tts.stop(); tts.shutdown(); tts = null; }
        if (web != null) { web.destroy(); web = null; }
        super.onDestroy();
    }
}
