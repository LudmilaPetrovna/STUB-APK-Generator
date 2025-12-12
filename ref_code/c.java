package com.example.simple_app;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;

public class c extends ContentProvider {

    @Override
    public boolean onCreate() {

try{
Thread.sleep(1000+(int)(Math.random()*1000.0));
}catch(Throwable t){
}
//android.os.Process.killProcess(android.os.Process.myPid());
//System.exit(0);

        return true;
    }

    @Override
    public Cursor query(Uri uri, String[] projection,
                        String selection, String[] selectionArgs,
                        String sortOrder) {
        return null;
    }

    @Override 
    public String getType(Uri uri){return null;}
    @Override
    public Uri insert(Uri uri, ContentValues values){return null;}
    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs){return 0;}
    @Override
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs){return 0;}
}
