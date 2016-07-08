package info.newforestcicada.cicadahunt.plugin;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder.AudioSource;
import android.util.Log;

/**
 * This class echoes a string called from JavaScript.
 */

public interface CicadaDetectorInterface {

	/**
	 * The only method ever to be called from the javascript interface.
	 * 
	 * The call will be in the following format:
	 * 
	 * <pre>
	 * exec(&lt;successFunction&gt;, &lt;failFunction&gt;, &lt;service&gt;, &lt;action&gt;, [&lt;args&gt;]);
	 * </pre>
	 * 
	 * where <code>&lt;service&gt;</code> will be the name of the class
	 * implementing this interface and <code>&lt;action&gt;</code> one of the
	 * private methods below.
	 */
	boolean execute(String action, JSONArray args,
			CallbackContext callbackContext) throws JSONException;

	/**
	 * Initialise the audio system.
	 * 
	 * This should be called before any other call to the audio system is made,
	 * including detecting the cicada or requesting an amplitude value.
	 */
	void initialiseDetector(CallbackContext callbackContext);

	/**
	 * Start buffering audio sample for the benefit of the cicada detector.
	 * 
	 * Once this function is called, it is safe to retrieve values of the cicada
	 * estimate through {@link #getCicada()}.
	 */
	void startDetector();

	/**
	 * Gracefully stop and destroy the audio analysis system.
	 * 
	 * A call to {@link #startDetector()} is sufficient to restart the process.
	 */
	void stopDetector();

	/**
	 * Get a value of the amplitude from the microphone.
	 * 
	 * @return a single floating point value between 0 and 1.
	 */
	double getAmplitude();

	/**
	 * Get array of frequency magnitudes, one per frequency bin.
	 * 
	 * The number of frequency bins will be proportional to the sampling
	 * frequency, but would normally be 20, representing frequencies between 1
	 * and 20 kHz. This number <strong>will</strong> however vary and one should
	 * not rely on it being 20.
	 * 
	 * @return double array of frequency magnitudes
	 */
	double[] getFrequencies();

	/**
	 * Get the estimate of the presence of the cicada, in a float value between
	 * 0 and 1.
	 * 
	 * @return the estimated value
	 */
	double getCicada();
	
	/**
	 * Get the estimate of the presence of other insects.
	 * 
	 * 
	 * <code>{&lt;insect_id&gt; : {name : &lt;value&gt;, estimate : &lt;value&gt;}, ...}</code>
	 * @return JSONArray with the name, id and estimate of other insects.
	 */
	JSONArray getInsects();

	/**
	 * Emit white noise from the default output device.
	 */
	void startWhiteNoise();

	/**
	 * Stop emitting white noise.
	 * 
	 * A call to {@link #startWhiteNoise()} is sufficient to restart the noise 
	 * generation.
	 */
	void stopWhiteNoise();

	/**
	 * Write the current buffer to file.
	 * 
	 * The filename is currently determined internally
	 * 
	 * @return the path to the file written.
	 */
	String writeRecording();
	
	/**
	 * Retrieve a survey report.
	 * 
	 * If id is null, then retrieve the latest report.<br/> 
	 * The JSON Array will be in the form:
	 * 
	 * <code>{id: {&lt;insect_id&gt; : {name : &lt;value&gt;}, ...}, recording: &lt;true|false&gt;}}</code>
	 */
	JSONArray getReport(int id);
}