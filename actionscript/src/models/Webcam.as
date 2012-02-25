package models
{
	import com.adobe.images.JPGEncoder;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import mx.collections.ArrayCollection;
	import mx.graphics.codec.JPEGEncoder;
	import net.metafor.faceapi.FaceApi;
	import net.metafor.faceapi.events.FaceEvent;
	import spark.components.List;

	[Bindable]
	public class Webcam extends EventDispatcher
	{
		public var camera:Camera;
		public var _camWidth:Number;
		public var _camHeight:Number;

		private var bmd:BitmapData = new BitmapData(600,400);//Creates a new BitmapData with the parameters as size
		private var bmp:Bitmap; //This bitmap will hold the bitmap data, which is the captured data from the webcam
		private var fileReference:FileReference = new FileReference(); //A file reference instance used to access the save to disk function
		private var byteArray:ByteArray; //This byte array instance will hold the data created from the jpg encoder and use it to save the image
		private var jpg:JPGEncoder = new JPGEncoder(90); //An instance of the jpg encoder class

		private var faceApi:FaceApi;
		private var faceApiNamespace:String;
		private var isTraining:Boolean;
		private var isRecognition:Boolean;
		public var userIdToAdd:String;
		private var _message:String;
		public var showMessageRect:Boolean = false;

		public function Webcam() {
			camWidth = 600;

			faceApi = new FaceApi();
			faceApi.apiKey = "3136ddde054c80b6b39ae0e9db867636";
			faceApi.apiSecret = "NOT_FOR_GITHUB";

			isTraining = false;
			isRecognition = false;
			faceApiNamespace = "@webarbeit";
			userIdToAdd = "";
		}

		// -----------------------------------------------------
		public function initWebcam():Boolean {
			camera = Camera.getCamera();
			if (camera) {
				camera.setMode(camWidth, camHeight, 24, false);
				camera.setQuality(0, 90);
				return true;
			} else {
				return false;
			}
		}

		// -----------------------------------------------------
		// Authenticate a face
		public function authenticate(bitmapData:BitmapData):void {
			trace("Going to recognize ... ");
			faceApi.recognitionService.addEventListener( FaceEvent.SUCCESS , onRecognizeSuccess);
			faceApi.recognitionService.addEventListener( FaceEvent.FAIL , onRecognizeFail);
			bmp = new Bitmap(bitmapData);
			message = "Searching ...";
			//
			faceApi.recognitionService.uploadAndRecognize(bmp , ["all" + faceApiNamespace] );
		}

		// Add new user to the face.com index
		public function addUser(bitmapData:BitmapData, userId:String):void {
			trace("Going to add new user ...");
			message = "Adding user to index ...";
			faceApi.recognitionService.addEventListener( FaceEvent.SUCCESS , onDetectSuccess );
			faceApi.recognitionService.addEventListener( FaceEvent.FAIL , onDetectFail );
			bmp = new Bitmap(bitmapData);
			isTraining = true;
			userIdToAdd = userId;
			//
			faceApi.recognitionService.uploadAndDetect(bmp);
		}

		//
		private function onDetectSuccess(evt:FaceEvent ):void {
			faceApi.recognitionService.removeEventListener( FaceEvent.SUCCESS , onDetectSuccess );

			trace(evt.rawResult);
			var tid:String = evt.data.photos[0].tags[0].tid;
			trace(tid);
			//
			if(isTraining && userIdToAdd.length > 0) {
				trace(userIdToAdd, tid);
				var username:String = userIdToAdd + faceApiNamespace;
				faceApi.tagsService.save( tid , username, userIdToAdd );
				isTraining = false;
				message = "User " + userIdToAdd + " added to the index";
			}
			showMessageRect = false;
		}

		//
		private function onRecognizeSuccess( evt : FaceEvent ):void {
			faceApi.recognitionService.removeEventListener( FaceEvent.SUCCESS , onRecognizeSuccess);
			try {
				var uid:String = evt.data.photos[0].tags[0].uids[0].uid;
				var confidence:String = evt.data.photos[0].tags[0].uids[0].confidence;
				trace(uid, confidence);
				message = "User " + uid + " found. Confidence: " + confidence + "%";
				var toJs:int = ExternalInterface.call("setVisitorName", uid);
			}
			catch(error:Error) {
				message = "User not found";
			}
		}

		//
		private function onDetectFail( evt : FaceEvent ):void {
			message = "Error while detecting face!";
		}

		//
		private function onRecognizeFail( evt : FaceEvent ):void {
			message = "Could not detect user";
		}

		public function saveImageToServer(bitmapData:BitmapData):Boolean {
			byteArray = jpg.encode(bitmapData);
			fileReference.save(byteArray, getRandomFilename() + ".jpg");
			return true;
		}

		// -----------------------------------------------------
		// Helper
		private function getRandomFilename():String {
			// Random filename
			var rndYear:Number = Math.floor(Math.random() * (1+2010-1970)) + 1970;
			var mlk:Date = new Date(rndYear, 0, 15);
			var tstamp:Number = mlk.getTime();
			var rndNum:Number = Math.floor(Math.random() * (1+1000-500)) + 500;
			var fname:Number = tstamp + rndNum;
			return fname.toString();
		}

		// -----------------------------------------------------
		// GETTER & SETTER
		public function get camWidth():Number {
			return _camWidth;
		}

		public function get camHeight():Number {
			return _camHeight;
		}

		public function set camHeight(value:Number):void {
			if(value == camHeight)
				return;

			_camHeight = value;
		}

		public function set camWidth(value:Number):void	{
			if(value == camWidth)
				return;

			_camWidth = value;

			camHeight = camWidth / 1.3;
		}

		public function get message():String {
			return _message;
		}

		public function set message(value:String):void {
			showMessageRect = true;
			_message = value;
		}

	}
}