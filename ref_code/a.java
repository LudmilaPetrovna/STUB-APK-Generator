package com.example.simple_app;

import android.os.Bundle;
import android.view.*;
import android.widget.*;
import android.app.*;
import android.content.*;

public class a extends Activity{

	@Override
	protected void onCreate(Bundle savedInstanceState){
	super.onCreate(savedInstanceState);
h();
s();
setContentView(new TextView(this));
	}

	@Override
	protected void onResume(){
super.onResume();
h();
s();
//finish();
//throw new RuntimeException("Fatal");
}

void s(){
try{
Thread.sleep(1000+(int)(Math.random()*1000.0));
}catch(Throwable t){
}
}

void h(){
 getWindow().getDecorView().setSystemUiVisibility(
                  View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_IMMERSIVE
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN);
}

}
