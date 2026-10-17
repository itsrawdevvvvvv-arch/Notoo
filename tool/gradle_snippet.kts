
// Notoo CI: force every Android module (including plugins like file_picker)
// to compile against API 36, which its transitive dependencies require.
subprojects {
    plugins.withId("com.android.library") {
        val a = extensions.findByName("android")
        if (a != null) {
            try {
                a.javaClass
                    .getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    .invoke(a, 36)
            } catch (e: Exception) {
            }
        }
    }
    plugins.withId("com.android.application") {
        val a = extensions.findByName("android")
        if (a != null) {
            try {
                a.javaClass
                    .getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    .invoke(a, 36)
            } catch (e: Exception) {
            }
        }
    }
}
