package info.newforestcicada.cicadahunt.plugin.insects;

import info.newforestcicada.cicadahunt.plugin.AudioAnalyser;
import info.newforestcicada.cicadahunt.plugin.LongTermResult;

import java.util.ArrayList;
import java.util.Collections;

import android.util.Log;

public class CommonFieldGrasshopper extends Insect {

	public static final int ID = 1;
	public static final String NAME = "Field Grasshopper";
	public static final int frequency = 14;
	public static final float threshold = 0.5f;
	
	public CommonFieldGrasshopper() {
		super(ID, NAME);
	}

	@Override
	public float getValue(float[] freqs) {
		float value = (float) (Math.log(freqs[10]) / Math.log(freqs[4]));
		return Math.max(0, (2 / (1 + (float) Math
				.exp(-AudioAnalyser.ratioScalingFactor * value)) - 1));
	}

	@Override
	public LongTermResult getLongTermResult() {
		ArrayList<Float> smoothValues = new ArrayList<Float>();
		smoothValues.add(0f);

		int moreThanThreshold = 0;
		int localMoreThanThresh = 0;
		ArrayList<Integer> allLocal = new ArrayList<Integer>(); 

		for (int i = 1; i < longTermValues.size(); i++) {
			float smoothValue = 0.9f * smoothValues.get(i - 1) + 0.1f
					* longTermValues.get(i);
			smoothValues.add(smoothValue);
			if (longTermValues.get(i) > threshold) {
				moreThanThreshold++;
				localMoreThanThresh++;
			} else {
				allLocal.add(localMoreThanThresh);
				localMoreThanThresh = 0;
			}
		}
		
		Integer sumLocal = 0;
		for (int i: allLocal) {
			sumLocal += i;
		}
		double meanLocal = sumLocal.doubleValue()/allLocal.size();
		

		LongTermResult result;

		if ( 	Collections.max(smoothValues) < threshold && 
				Collections.max(longTermValues) > threshold &&
				moreThanThreshold > 0.02 * longTermValues.size()) {
			float confidence = Collections.max(longTermValues);
			if (meanLocal > 1.5 && meanLocal < 2.5) confidence = Math.min(1.1f*confidence, 1.0f);
			result = new LongTermResult(true, confidence);
		} else {
			result = new LongTermResult(false, 1 - Collections.max(smoothValues));
		}
		return result;

	}

}
