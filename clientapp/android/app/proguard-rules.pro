## Flutter-specific ProGuard rules

# Suppress warnings for missing classes from OpenTelemetry/Jackson (Firebase transitive deps)
-dontwarn com.fasterxml.jackson.core.JsonFactory
-dontwarn com.fasterxml.jackson.core.JsonGenerator
-dontwarn com.google.auto.value.AutoValue$CopyAnnotations
