﻿package appManager.displayContentElemets
	//appManager.displayContentElemets.LightImage
{
	
	import contents.alert.Alert;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import netManager.urlSaver.URLSaver;
	import netManager.urlSaver.URLSaverEvent;
	
	import wrokersJob.WorkerFunctions;
	import mteam.FuncManager;

	/**Image loading completed*/
	[Event(name="complete", type="flash.events.Event")]
	/**image loadin faild*/
	[Event(name="unload", type="flash.events.Event")]
	/**This class will resize the loaded image to its size to prevent gpu process and also it will crop the image to.*/
	public class LightImage extends Image
	{
		/**If the image item name contains below string, it will make it show image in the area and do not crop it*/
		public static const _full:String = "_full";
		
		
		/**This will make image to load in the stage with fade in animation*/
		public static var acitvateAnimation:Boolean = true ;
		
		/**You can cansel all animation by changing the static value activateAnimation*/
		public var animated:Boolean = true ;
		
		/**Pass numbers to this variable befor setup function to make it blur the image*/
		public var blur:Number = 0 ;
		
		public var animatedIfLoaded:Boolean = true ;
		
		/**This boolean will be true if the image was loaded earlier*/
		private var wasLoadedBefor:Boolean ;
		
		public var grayScaledImage:Boolean = false ;
		
		/**0 to 1*/
		public var animateSpeed:Number = 0 ;
		
		private var //loader:Loader ,
					urlSaver:URLSaver; 
		
		private var W:Number=0,H:Number=0,
					LoadInThisArea:Boolean;
					
		private var timeOutValue:uint ;
		
		private var loadedBytes:ByteArray ;
		private var loadedBitmap:BitmapData ;
		
		private var backColor:uint,
					backAlpha:Number;
					
		private var keepImageRatio:Boolean ;

		protected var newBitmap:Bitmap;

		//private var fileStreamLoader:FileStream;
		
		
		private static var watermarkBitmapData:BitmapData ;

		private var _watermarkBitmapDataForThis:BitmapData ;
		
		
		private var _watermark:Boolean = true ;
		private var IsLoading:Boolean;
		private var imageLoaderTimeOutId:uint;

		public static var activateAsyncImageRendered:Boolean = true ;
		
		/**This is the maximom delay for waiting to cpu cool down*/
		//private var maximomImageLoadingDelay:Number = 8000 ;
		
		//private var minimomImageLoadingDelay:Number = 4000 ;

		private var remove_cash:Boolean = false ;
		private var remove_file_target:String = null ;
		
		
		public function LightImage(BackColor:uint=0x000000,BackAlpha:Number=0)
		{
			backColor = BackColor ;
			backAlpha = BackAlpha ; 
			super();
			
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}

		public function dontCashImage():void
		{
			remove_cash = true ;
		}
		
		/**Change the icon size*/
		public function changeSize(newWidth:Number=0,newHeight:Number=0):void
		{
			W = newWidth ;
			H = newHeight ;
		}
		
		/**This function will returns the loaded image bitmap*/
		public function getBitmapData():BitmapData
		{
			if(newBitmap!=null)
			{
				return newBitmap.bitmapData ;
			}
			return null ;
		}
		
		/**Returns true if it is in the loading progress*/
		public function isLoading():Boolean
		{
			return IsLoading ;
		}
		
		/**Returns true if this light image can get watermark*/
		private function isWatermarkEnabled():Boolean
		{
			return watermarkBitmapData!=null && _watermark ;
		}
		
		/**Change the watermark status*/
		public function set watermark(value:Boolean):void
		{
			_watermark = value ;
		}
		
		override public function get height():Number
		{
			if(H==0)
			{
				return super.height;
			}
			return H*this.scaleY ;
		}
		
		override public function get width():Number
		{
			if(W==0)
			{
				return super.width;
			}
			return W*this.scaleY ;
		}
		
		/**Second setting up the LightImage class*/
		public function setUp2(doAnimation:Boolean = true):void
		{
			animated = doAnimation ;
		}
		
		/**You can show loaded image by this methode.*/
		public function setUpBytes(imageBytes:ByteArray, loadInThisArea:Boolean=false, imageW:Number=0, imageH:Number=0, X:Number=0, Y:Number=0,copyBytes:Boolean=false,keepRatio:Boolean=true):void
		{
			if(imageBytes==null)
				return;
			clearLastByte();
			if(copyBytes)
			{
				loadedBytes = new ByteArray();
				loadedBytes.writeBytes(imageBytes) ;
			}
			else
			{
				loadedBytes = imageBytes ;
			}
			clearLastBitmap();
			setUp(null, loadInThisArea, imageW, imageH, X, Y,keepRatio);
		}
		
		/**You can show loaded image by this methode.*/
		public function setUpBitmapData(imageBitmap:BitmapData, loadInThisArea:Boolean=false, imageW:Number=0, imageH:Number=0, X:Number=0, Y:Number=0,copyBitmap:Boolean=false,keepRatio:Boolean = true ):void
		{
			clearLastByte();
			clearLastBitmap();
			if(copyBitmap)
			{
				loadedBitmap = imageBitmap.clone() ;
			}
			else
			{
				loadedBitmap = imageBitmap ;
			}
			setUp(null, loadInThisArea, imageW, imageH, X, Y,keepRatio);
		}
		
		private function clearLastByte():void
		{
			if(loadedBytes)
			{
				loadedBytes.clear();
				loadedBytes = null ;
			}
		}
		
		private function clearLastBitmap():void
		{
			if(loadedBitmap!=null)
			{
				loadedBitmap.dispose();
				loadedBitmap = null ;
			}
		}
		
		
		/**This class will resize the loaded image to its size to prevent gpu process and also it will crop the image to.<br>
		 * pass -1 for each dimention to make the original value to use on that side*/
		override public function setUp(imageURL:String, loadInThisArea:Boolean=false, imageW:Number=0, imageH:Number=0, X:Number=0, Y:Number=0,keepRatio:Boolean=true):void
		{
			//PerformanceTest.traceDelay(1);
			//SaffronLogger.log("Load this image : "+imageURL);
			if(URL!=null && URL == imageURL)
			{
				SaffronLogger.log("current image is same as old image on lightImage");
				this.dispatchEvent(new Event(Event.COMPLETE));
				return ;
			}
			if(imageURL==null && loadedBytes==null && loadedBitmap==null)
			{
				SaffronLogger.log("No URL and no LoadedBytes defined yet");
				return ;
			}
			IsLoading = true ;
			if(imageURL!=null)
			{
				clearLastByte();
				clearLastBitmap();
			}
			URL = imageURL;
			if(imageW==-1)
			{
				W = 0 ;
			}
			else if(imageW!=0)
			{
				W = imageW;
			}
			else
			{
				W = super.width ;
			}
			
			if(imageH==-1)
			{
				H = 0 ;
			}
			else if(imageH!=0)
			{
				H = imageH;
			}
			else
			{
				H = super.height;
			}
			
			keepImageRatio = keepRatio ;
			//I dont want to remove content for this 
				this.removeChildren();

			this.graphics.clear();
			this.graphics.beginFill(backColor,backAlpha);
			this.graphics.drawRect(0,0,W,H);
			
			LoadInThisArea = loadInThisArea ;
			if(this.name.indexOf(_full)!=-1)
			{
				SaffronLogger.log("Load in this area type changed because of its name");
				LoadInThisArea = true ;
			}
			
			if(X!=0)
			{
				this.x = X ;
			}
			if(Y!=0)
			{
				this.y=Y;
			}
			//PerformanceTest.traceDelay(2);
			if(this.stage!=null)
			{
				startWork(null);
			}
			else
			{
				this.addEventListener(Event.ADDED_TO_STAGE,startWork);
			}
			this.scaleX = this.scaleY = 1 ;
			
			SaffronLogger.log("The imge W was "+W+" when you called to open image");
		}
		
		protected function startWork(event:Event=null):void
		{
			//SaffronLogger.log("Start to load");
			/*if(CPUController.isSatUp && animated)
			{
				CPUController.eventDispatcher.addEventListener(CPUEvents.PERVECT_CPU,startLoading);
				imageLoaderTimeOutId = setTimeout(startLoading,minimomImageLoadingDelay+(maximomImageLoadingDelay-minimomImageLoadingDelay)*Math.random());
			}
			else
			{
				startLoading();
			}*/
			if(activateAsyncImageRendered)
				FuncManager.callAsyncOnFrame(startLoading);
			else
				startLoading();
		}
		
		/**This will make images to load*/
		public function startLoading(e:*=null):void
		{
			////PerformanceTest.traceDelay(3);
			if(this.stage==null)
				return;
			clearTimeout(imageLoaderTimeOutId);
			/*if(CPUController.isSatUp)
			{
				CPUController.eventDispatcher.removeEventListener(CPUEvents.PERVECT_CPU,startLoading);
			}*/
			urlSaver = new URLSaver(true);
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			if(URL!=null)
			{
				urlSaver.addEventListener(URLSaverEvent.LOAD_COMPLETE,imageSaved);
				urlSaver.addEventListener(URLSaverEvent.NO_INTERNET,imageNotFound);
				urlSaver.load(URL);
			}
			else if(loadedBytes!=null)
			{
				//The byte array should loaded befor
				imageSaved();	
			}
			else if(loadedBitmap!=null)
			{
				imageLoaded();
			}
		}
		
		/**If you pass null to this functino, it will use loadedBytes valeu*/
		protected function imageSaved(event:URLSaverEvent=null):void
		{
			wasLoadedBefor = event==null || event.wasLoadedBefor ;
			//PerformanceTest.traceDelay('image is loaded');
			//var loaderContext:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
			//SaffronLogger.log("Load this image : "+event.offlineTarget);
			//loader = new Loader();
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE,imageLoaded);
			//loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,imageNotFound);
			if(event!=null)
			{
				/*if(fileStreamLoader)
				{
					fileStreamLoader.close();
					fileStreamLoader = null ;
				}
				fileStreamLoader = new FileStream();
				fileStreamLoader.addEventListener(Event.COMPLETE,fileLoaded);
				try
				{
					SaffronLogger.log("Try to load : "+event.offlineTarget);
					
					//PerformanceTest.traceDelay('create target file');
					var targetFile:File = new File(event.offlineTarget) ;
					//PerformanceTest.traceDelay('Target file created');
					if(targetFile.exists)
					{
						//PerformanceTest.traceDelay('open file async');
						fileStreamLoader.openAsync(targetFile,FileMode.READ);
						//PerformanceTest.traceDelay('async loaded');
					}
					else{
						throw "The file is not exists" ;
					}
				}
				catch(e)
				{
					SaffronLogger.log("Light image async file loader errr : "+e);
					fileStreamLoader.close();
					fileStreamLoader = null ;*/
					//Alert.show("event.offlineTarget : "+event.offlineTarget);
				SaffronLogger.log("**** event.offlineTarget on lightImage : "+event.offlineTarget);
				if(remove_cash)
				{
					remove_file_target = event.offlineTarget ;
				}
					WorkerFunctions.createBitmapFromByte(event.offlineTarget,imageLoaded,LoadInThisArea,W,H,keepImageRatio,blur);
					//loader.load(new URLRequest(),loaderContext);
				//}
			}
			else
			{
				loadedBytes.position = 0 ;
				//loaderContext.allowLoadBytesCodeExecution = true ;
				var tim:Number = getTimer();
				WorkerFunctions.createBitmapFromByte(loadedBytes,imageLoaded,LoadInThisArea,W,H,keepImageRatio,blur);
				//loader.loadBytes(loadedBytes,loaderContext);
				SaffronLogger.log(">>> "+(getTimer()-tim));
			}
		}
		
		/*protected function fileLoaded(event:Event):void
		{
			//SaffronLogger.log("\t*\tImage loaded as file");
			var loaderContext:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
			var bytes:ByteArray = new ByteArray();
			try
			{
				fileStreamLoader.readBytes(bytes);
				//PerformanceTest.traceDelay('file loaded. show the image');
				var tim:Number = getTimer();
				WorkerFunctions.createBitmapFromByte(bytes,imageLoaded,LoadInThisArea,W,H,keepImageRatio);
				//loader.loadBytes(bytes,loaderContext);
				SaffronLogger.log("*>>> "+(getTimer()-tim));
				//PerformanceTest.traceDelay('image file showed');
				fileStreamLoader.close();
				bytes.clear();
			}
			catch(e)
			{
				SaffronLogger.log("Light image loading local file error : "+e);
			}
		}*/
		
		protected function imageNotFound(event:*):void
		{
			
			this.dispatchEvent(new Event(Event.UNLOAD));
			
			timeOutValue = setTimeout(startWork,10000);
		}
		
		protected function imageLoaded(workerArray:Array=null):void
		{
			
			//PerformanceTest.traceDelay('image loader loaded the image');
			clearTheBitmap();
			var workerBitmap:BitmapData ;
			//var loadedContent:DisplayObject ;
			/*if(loader==null && loadedBitmap==null)
			{
				SaffronLogger.log("*************************why the loader is null???"+loader+' > '+event+'  >>  '+(event.target as LoaderInfo)+'  >>>  '+event.currentTarget);
				loadedContent = (event.target as LoaderInfo).content;
				//return;
			}*/
			if(workerArray is Array && workerArray.length==1)
			{
				//Alert.show("Image had problem"+workerArray[0]);
				imageNotFound(null);
				return ;
			}
			if(newBitmap)
			{
				newBitmap.bitmapData.dispose();
				Obj.remove(newBitmap);
			}
			if(loadedBitmap!=null)
			{
				newBitmap = new Bitmap(loadedBitmap);
			}
			else if(workerArray!=null && workerArray is Array && workerArray.length>1 && (workerArray[0] is ByteArray))
			{
				SaffronLogger.log("The image file is : "+workerArray[0].length);
				SaffronLogger.log("The image file W : "+workerArray[1]);
				SaffronLogger.log("The image file H : "+workerArray[2]);
				(workerArray[0] as ByteArray).position = 0 ;
				workerBitmap = new BitmapData(workerArray[1],workerArray[2],true,0x00000000);
				workerBitmap.setPixels(workerBitmap.rect,workerArray[0]);
				
				newBitmap = new Bitmap(workerBitmap);
			}
			/*else
			{
				if(loadedContent)
				{
					newBitmap = loadedContent as Bitmap ;
				}
				else
				{
					newBitmap = (loader.content as Bitmap);
				}
			}*/
			if(newBitmap==null)
			{
				SaffronLogger.log("Image load faild on lightImage function imageLoaded");
				return ;
			}
			if(workerBitmap==null)
			{
				var bitmapData:BitmapData = newBitmap.bitmapData ;
				//var newBitmapData:BitmapData ;
				SaffronLogger.log("The W is : "+W);
				SaffronLogger.log("The H is : "+H);
				if(W!=0 && H!=0)
				{
					SaffronLogger.log("Change image size to : "+W,H);
					bitmapData = BitmapEffects.changeSize(bitmapData,W,H,keepImageRatio,LoadInThisArea);
				}
				else if(W!=0)
				{
					//SaffronLogger.log("• I whant to change the bitmap width to : "+W);
					//SaffronLogger.log("And the height will be "+bitmapData.height*(W/bitmapData.width));
					bitmapData = BitmapEffects.changeSize(bitmapData,W,bitmapData.height*(W/bitmapData.width),keepImageRatio,LoadInThisArea);
					H = bitmapData.height;
				}
				else if(H!=0)
				{
					//SaffronLogger.log("• I whant to change the bitmap height to : "+H);
					//SaffronLogger.log("And the width will be "+bitmapData.width*(H/bitmapData.height));
					bitmapData = BitmapEffects.changeSize(bitmapData,bitmapData.width*(H/bitmapData.height),H,keepImageRatio,LoadInThisArea);
					W = bitmapData.width;
				}
				else//(Both H and W are 0)
				{
					bitmapData = bitmapData.clone();
					W = bitmapData.width;
					H = bitmapData.height;
				}
				
				if(blur>0)
				{
					BitmapEffects.blur(bitmapData,blur);
				}
			}
			else
			{
				bitmapData = workerBitmap ;
			}
			
			
			/*if(loader)
			{
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,imageLoaded);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,imageNotFound);
				(loader.content as Bitmap).bitmapData.dispose();
				loader.unloadAndStop();
				loader.unload();
				loader = null ;
			}*/
		
			
			if(isWatermarkEnabled())
			{
				var myWatermark:BitmapData = BitmapEffects.changeSize(watermarkBitmapData,bitmapData.width,bitmapData.height,true,true,true);
				bitmapData.draw(myWatermark);
				myWatermark.dispose();
			}
			if(_watermarkBitmapDataForThis!=null)
			{
				var myWatermark2:BitmapData = BitmapEffects.changeSize(_watermarkBitmapDataForThis,bitmapData.width,bitmapData.height,true,true,true);
				bitmapData.draw(myWatermark2);
				myWatermark2.dispose();
			}
			
			if(grayScaledImage)
			{
				bitmapData = BitmapEffects.setGrayScale(bitmapData);
			}
			newBitmap.bitmapData = bitmapData;
			newBitmap.smoothing = true ;
			//this.addChild(newBitmap);
			
			//I will try to load image in imageContainer to controll mask but on Android
			var imageContainer:Sprite = new Sprite();
			this.addChild(imageContainer);
			imageContainer.addChild(newBitmap);
			
			if(acitvateAnimation && animated || (!wasLoadedBefor && animatedIfLoaded))
			{
				this.alpha = 0 ;
				//SaffronLogger.log("make it come with animation : "+this);
				AnimData.fadeIn(this,null,animateSpeed);
			}
			
			IsLoading = false;
			//PerformanceTest.traceDelay("Now image is ready to show");
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function clearTheBitmap():void
		{
			if(remove_file_target!=null)
			{
				FileManager.deleteFile(new File(remove_file_target));
				remove_file_target = null ;
			}
			if(newBitmap!=null)
			{
				if(newBitmap.bitmapData!=null)
				{
					newBitmap.bitmapData.dispose() ;
				}
			}
		}
		
		protected function unLoad(event:Event):void
		{
			WorkerFunctions.removeFunction(imageLoaded);
			clearTimeout(imageLoaderTimeOutId);
			clearTimeout(timeOutValue);
			/*if(CPUController.isSatUp)
			{
				CPUController.eventDispatcher.removeEventListener(CPUEvents.PERVECT_CPU,startLoading);
			}*/
			
			/*if(fileStreamLoader)
			{
				fileStreamLoader.close();
			}*/
			
			if(loadedBytes!=null)
			{
				try
				{
					loadedBytes.clear();
				}
				catch(e){};
			}
			clearTheBitmap();
			
			if(urlSaver!=null)
			{
				urlSaver.removeEventListener(URLSaverEvent.LOAD_COMPLETE,imageSaved);
				urlSaver.removeEventListener(URLSaverEvent.NO_INTERNET,imageNotFound);
			}
			/*try
			{
				loader.close();
			}
			catch(e)
			{
				//SaffronLogger.log("LightImage problem : "+e);
			}*/
		}
		
		public static function addWaterMark(watermarkTarget:File):void
		{
			
			DeviceImage.loadFile(onWatermarkLoaded,watermarkTarget)
		}
		
		public function addWaterMark(watermarkBitmapData:BitmapData):void
		{
			
			_watermarkBitmapDataForThis = watermarkBitmapData ;
		}
		
			private static function onWatermarkLoaded():void
			{
				watermarkBitmapData = DeviceImage.imageBitmapData ;
			}
	}
}