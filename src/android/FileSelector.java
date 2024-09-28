package com.example.fileselector;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONObject;

import android.content.Intent;
import android.net.Uri;
import android.database.Cursor;
import android.provider.OpenableColumns;
import android.webkit.MimeTypeMap;
import android.content.Context;

public class FileSelector extends CordovaPlugin {
    private static final int PICK_FILES = 1;
    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
        if (action.equals("selectFiles")) {
            this.callbackContext = callbackContext;
            openFileSelector();
            return true;
        }
        return false;
    }

    private void openFileSelector() {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
        cordova.startActivityForResult(this, intent, PICK_FILES);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == PICK_FILES && resultCode == cordova.getActivity().RESULT_OK) {
            JSONArray resultArray = new JSONArray();
            if (data.getClipData() != null) {
                // Multiple files selected
                for (int i = 0; i < data.getClipData().getItemCount(); i++) {
                    Uri uri = data.getClipData().getItemAt(i).getUri();
                    resultArray.put(getFileMetadata(uri));
                }
            } else if (data.getData() != null) {
                // Single file selected
                Uri uri = data.getData();
                resultArray.put(getFileMetadata(uri));
            }

            callbackContext.success(resultArray);
        } else {
            callbackContext.error("File selection canceled");
        }
    }

    private JSONObject getFileMetadata(Uri uri) {
        JSONObject fileData = new JSONObject();
        Context context = cordova.getActivity().getApplicationContext();
        Cursor cursor = context.getContentResolver().query(uri, null, null, null, null);

        try {
            if (cursor != null && cursor.moveToFirst()) {
                String displayName = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                String mimeType = context.getContentResolver().getType(uri);
                fileData.put("filename", displayName);
                fileData.put("filemime", mimeType);
                fileData.put("fileUri", uri.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            cursor.close();
        }

        return fileData;
    }
}
