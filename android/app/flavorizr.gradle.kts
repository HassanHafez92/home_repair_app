import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("production") {
            dimension = "flavor-type"
            applicationId = "com.example.home_repair_app"
            resValue(type = "string", name = "app_name", value = "Home Repair")
        }
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.example.home_repair_app.dev"
            resValue(type = "string", name = "app_name", value = "Home Repair (DEV)")
        }
        create("stg") {
            dimension = "flavor-type"
            applicationId = "com.example.home_repair_app.stg"
            resValue(type = "string", name = "app_name", value = "Home Repair (STG)")
        }
        create("uat") {
            dimension = "flavor-type"
            applicationId = "com.example.home_repair_app.uat"
            resValue(type = "string", name = "app_name", value = "Home Repair (UAT)")
        }
    }
}