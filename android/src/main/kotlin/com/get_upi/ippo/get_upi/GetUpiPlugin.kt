package com.get_upi.ippo.get_upi

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import android.util.Base64
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.util.*


/** GetUpiPlugin */
class GetUpiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private lateinit var activity: ActivityPluginBinding
    private lateinit var result: Result

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "GET_UPI_IPPO")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding
        binding.addActivityResultListener(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull _result: Result) {
        result = _result
        when (call.method) {
            "get_available_upi" -> {
                _result.success(getUpiAppList(activity.activity.applicationContext))
            }
            "native_intent" -> {
                val url = call.argument<String>("url")
                openUpiIntent(url!!, activity, result)
            }
            "open_upi_app" -> {
                val url = call.argument<String>("url")
                val packageName = call.argument<String>("package")
                openUpiApp(url!!, packageName!!)
            }
        }
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun getUpiAppList(context: Context): String {

        val uriBuilder:Uri.Builder =  Uri.Builder();
        uriBuilder.scheme("upi").authority("pay");
        uriBuilder.appendQueryParameter("pa", "test@ybl");
        uriBuilder.appendQueryParameter("pn", "Test");
        uriBuilder.appendQueryParameter("tn", "Get All Apps");
        uriBuilder.appendQueryParameter("am", "1.0");
        uriBuilder.appendQueryParameter("cr", "INR");

        val application = JSONArray()
        val packageManager = context.packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null)
        mainIntent.addCategory(Intent.CATEGORY_DEFAULT)
        mainIntent.addCategory(Intent.CATEGORY_BROWSABLE)
        mainIntent.action = Intent.ACTION_VIEW
        val uri = Uri.Builder().scheme("upi").authority("pay").build()
        mainIntent.data = uri

        val pkgAppsList: List<*> = context.packageManager.queryIntentActivities(mainIntent, 0)

        for (i in pkgAppsList.indices) {

            val resolveInfo = pkgAppsList[i] as ResolveInfo

            if (!isWhatsapp(resolveInfo.activityInfo.packageName) && isAppUpiReady(resolveInfo.activityInfo.packageName, context)) {

                val obj = JSONObject()
                obj.put("name", resolveInfo.loadLabel(packageManager).toString())
                obj.put("package_name", resolveInfo.activityInfo.packageName)
                obj.put("icon", getBitmapFromDrawable(resolveInfo.loadIcon(packageManager)))

                application.put(obj)
            }
        }

        val data = JSONObject()
        data.put("data", application)

        print(application)

        return data.toString()
    }

    private fun openUpiIntent(url : String, activity: ActivityPluginBinding, result: MethodChannel.Result) {


        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        if (intent.resolveActivity(activity.activity.packageManager) != null) {
            activity.activity.startActivityForResult(intent, 121)
        } else {
//            Toast.makeText(activity.activity, "Please make sure you've installed UPI apps", Toast.LENGTH_LONG).show()
            result.success("Please make sure you've installed UPI apps")
        }
    }

    private fun isWhatsapp(packageName: String): Boolean {
        return clearNull(packageName).equals("com.whatsapp", ignoreCase = true)
    }

    private fun isAppUpiReady(packageName: String, context: Context): Boolean {




        var appUpiReady = false
        val upiIntent = Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"))
//        val upiIntent = Intent(Intent.ACTION_VIEW, Uri.parse("upi://mandate?pa=ippoautopay@icici&pn=IPPOPAY%20TECHNOLOGIES&tr=EZM2023070112223506269543&am=2000.00 &cu=INR&orgid=400011&mc=5818&purpose=14&tn=Mandate%20for%20Sound%20box&validitystart=01072023&validityend=01072053&amrule=MAX&recur=ASPRESENTED&rev=Y&share=Y&block=N&txnType=CREATE&mode=13"))
        val pm = context.packageManager
        val upiActivities: List<ResolveInfo> = pm.queryIntentActivities(upiIntent, 0)
        for (a in upiActivities){
            if (a.activityInfo.packageName == packageName) appUpiReady = true
        }
        return appUpiReady
    }

    private fun clearNull(value: String?): String {
        return if (value.isNullOrEmpty()) "" else value.trim()
    }

    private fun getBitmapFromDrawable(drawable: Drawable): String? {
        val bmp: Bitmap = Bitmap.createBitmap(
                drawable.intrinsicWidth,
                drawable.intrinsicHeight,
                Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bmp)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        val byteArrayOS = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOS)

        return Base64.encodeToString(byteArrayOS.toByteArray(), Base64.NO_WRAP)
    }

    private fun openUpiApp(data: String, packageName: String) {
        val intent = Intent()
        intent.action = Intent.ACTION_VIEW
        intent.setPackage(packageName)
        intent.data = Uri.parse(data)
        activity.activity.startActivityForResult(intent, 121)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {

        if (requestCode == 121) {
            if (Activity.RESULT_OK == resultCode || resultCode == 11) {
                if (data != null) {
                    val trxt = data.getStringExtra("response")
                    //                    Log.d("UPI", "onActivityResult: " + trxt);
                    val dataList = ArrayList<String?>()
                    dataList.add(trxt)

                    upiPaymentDataOperation(dataList)
                } else {
//                    Log.d("UPI", "onActivityResult: " + "Return data is null");
                    val dataList = ArrayList<String?>()
                    dataList.add("nothing")

                    upiPaymentDataOperation(dataList)
                }
            } else {
                val dataList = ArrayList<String?>()
                dataList.add("nothing")

                upiPaymentDataOperation(dataList)
            }
        }
        return true
    }

    private fun upiPaymentDataOperation(data: ArrayList<String?>) {
        try {
            var str = data[0]
            var paymentCancel = ""
            if (str == null) str = "discard"
            var status = ""
            var approvalRefNo = ""
            val response = str.split("&".toRegex()).toTypedArray()
            Log.i("PASSED ARRAY", data.toString())
            for (i in response.indices) {
                val equalStr = response[i].split("=".toRegex()).toTypedArray()
                if (equalStr.size >= 2) {
                    if (equalStr[0].equals("Status", ignoreCase = true)) {
                        status = equalStr[1].lowercase(Locale.getDefault())
                    } else if (equalStr[0].equals(
                            "ApprovalRefNo",
                            ignoreCase = true
                        ) || equalStr[0].equals("txnRef", ignoreCase = true)
                    ) {
                        approvalRefNo = equalStr[1]
                    }
                } else {
                    paymentCancel = "Payment cancelled by user."
                }
            }
            if (status == "success") {
                result.success("Success")

            } else if ("Payment cancelled by user." == paymentCancel || status.contains("failure")) {
                result.success("Payment cancelled by user")
            } else {
                result.success("Transaction failed.Please try again")
            }
        } catch (e: Exception) {
            Log.i("Exception Native", e.toString())
        }
    }


    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivity() {

    }


}
