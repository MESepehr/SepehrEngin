package appManager.displayContentElemets
	//appManager.displayContentElemets.TitleText
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class TitleText extends MovieClip
	{
		protected var myText:TextField ;
		public static const LEFT:String = "LEFT",
							RIGHT:String = "RIGHT";
		
		
		private var title:String;
		private var arabicText:Boolean;
		private var replaceWithBitmap:Boolean;
		private var resolution:uint;
		private var splitIfToLong:Boolean;
		private var dynamicWidth:Boolean;
		
		public function TitleText()
		{
			super();
			
			myText = Obj.get("text_txt",this);
			if(myText==null)
			{
				myText = Obj.findThisClass(TextField,this);
			}
			myText.multiline = false ;
			myText.text = '';
		}
		
		public function setUp(title:String,arabicText:Boolean = true,splitIfToLong:Boolean=false,resolution:uint=0,replaceWithBitmap:Boolean=true,dynamicWidth:Boolean=false):void
		{
			this.title = title;
			this.arabicText = arabicText ;
			this.replaceWithBitmap = replaceWithBitmap;
			this.resolution = resolution;
			this.splitIfToLong = splitIfToLong;
			this.dynamicWidth = dynamicWidth;
			
			updateInterface();
		}
		
		private function updateInterface():void
		{
			TextPutter.OnButton(myText,title,arabicText,replaceWithBitmap,true,false,resolution,splitIfToLong,dynamicWidth);			
		}
		/**setup and split text by any car*/
		public function setUp2(title:String,arabicText:Boolean = true,splitIfToLong:Boolean=false,resolution:uint=0,replaceWithBitmap:Boolean=true,splitRange_p:int=0,car_p:String=',',direction_p:String=TitleText.RIGHT,reverse_p:Boolean=false):void
		{
			if(splitRange_p>0)
			{
				title = split(title,splitRange_p,car_p,direction_p,reverse_p);
			}
			TextPutter.OnButton(myText,title,arabicText,replaceWithBitmap,true,false,resolution,splitIfToLong);
		}

		override public function set width(value:Number):void
		{
			myText.width = value;
			updateInterface();
		}
		
		override public function set height(value:Number):void
		{
			//Dont change the title text height
			myText.height = value;
			updateInterface();
		}
		
		public function get text():String
		{
			return myText.text ;
		}
		
		public function set text(string:String):void
		{
			setUp(string);
		}
		
		public function color(colorNum:uint):void
		{
			SaffronLogger.log("The color is : "+colorNum);
			
			myText.textColor = colorNum ;
		}

		public function changeFontSize(newFontSize:int,updateInterfaceInstantly:Boolean=false):void
		{
			var textFormat:TextFormat = myText.defaultTextFormat ;
			textFormat.size = newFontSize;
			myText.setTextFormat(textFormat);
			myText.defaultTextFormat = textFormat ;
			if(updateInterfaceInstantly)
				updateInterface();
		}
		
		public function setUpMultiline(content:String,arabicText:Boolean = true,resolution:uint=0):void
		{
			
			TextPutter.onTextArea(myText,content,arabicText,true,false,resolution);
		}
		private  function split(value_p:String,splitRange_p:int,car_p:String,direction_p:String,reverse_p:Boolean=false):String
		{
			var splitValueArray:Array = new Array();
			var valToString:String = value_p;
			var splitDotArray:Array = valToString.split('.');	
			valToString = splitDotArray[0];
			var flot:String = splitDotArray[1];
			var split:String	
			while(valToString.length>splitRange_p)
			{
				if(direction_p == RIGHT)
				{
					split = valToString.substr(valToString.length-splitRange_p,valToString.length)
					valToString = valToString.substr(0,valToString.length-splitRange_p)	
					splitValueArray.push(split)
				}
				else if(direction_p == LEFT)
				{
					split = valToString.substr(0,splitRange_p)
					valToString = valToString.substr(splitRange_p,valToString.length)
					splitValueArray.push(split)
				}
			}	
			if(valToString.length!=0)splitValueArray.push(valToString)			
			if(direction_p == RIGHT)splitValueArray.reverse()
			
			// for edit text 	
			if(reverse_p)splitValueArray.reverse()
			var price:String = splitValueArray.join(car_p);
			if(flot!=null && flot!='')
			{
				price+='.'+flot;
			}
			return price;
		}

	}
}