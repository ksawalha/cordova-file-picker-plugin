package org.apache.cordova.pickers;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.app.Activity;
import android.net.Uri;
import android.database.Cursor;
import android.provider.OpenableColumns;
import android.Manifest;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;

public class FilePicker extends CordovaPlugin {

    private static final int PICK_FILES = 1;
    private static final int REQUEST_PERMISSIONS = 100;
    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
        if (action.equals("selectFiles")) {
            this.callbackContext = callbackContext;
            // Check for permissions
            if (ActivityCompat.checkSelfPermission(cordova.getActivity(), Manifest.permission.READ_EXTERNAL_STORAGE) 
                != PackageManager.PERMISSION_GRANTED) {
                // Request permission
                ActivityCompat.requestPermissions(cordova.getActivity(), 
                    new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, REQUEST_PERMISSIONS);
            } else {
                // Permission already granted
                openFilePicker();
            }
            return true;
        }
        return false;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == REQUEST_PERMISSIONS) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted, open file picker
                openFilePicker();
            } else {
                callbackContext.error("Permission denied to read external storage");
            }
        }
    }

    private void openFilePicker() {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.setType("*/*");
        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        this.cordova.startActivityForResult(this, intent, PICK_FILES);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == PICK_FILES) {
            if (resultCode == Activity.RESULT_OK) {
                JSONArray resultArray = new JSONArray();
                if (data.getClipData() != null) {
                    int count = data.getClipData().getItemCount();
                    for (int i = 0; i < count; i++) {
                        Uri fileUri = data.getClipData().getItemAt(i).getUri();
                        JSONObject fileData = getFileMetadata(fileUri);
                        if (fileData != null) {
                            resultArray.put(fileData);
                        }
                    }
                } else if (data.getData() != null) {
                    Uri fileUri = data.getData();
                    JSONObject fileData = getFileMetadata(fileUri);
                    if (fileData != null) {
                        resultArray.put(fileData);
                    }
                }
                callbackContext.success(resultArray);
            } else {
                callbackContext.error("File selection canceled");
            }
        }
    }

    private JSONObject getFileMetadata(Uri uri) {
        try {
            JSONObject fileData = new JSONObject();
            Cursor cursor = cordova.getActivity().getContentResolver().query(uri, null, null, null, null);
            if (cursor != null && cursor.moveToFirst()) {
                String displayName = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                String mimeType = cordova.getActivity().getContentResolver().getType(uri);
                fileData.put("filename", displayName);
                fileData.put("filemime", mimeType);
                fileData.put("filepath", uri.toString());
                cursor.close();
            }
            return fileData;
        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }
    }
}
