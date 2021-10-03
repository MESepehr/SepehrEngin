﻿/**
 * 
				//☻s are removed Ys in current version
 * 
 * 
 */

package popForm
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import com.mteamapp.StringFunctions;
	import flash.text.ReturnKeyLabel;
	
	[Event(name="buttonSelecte", type="popForm.PopMenuEvent")]
	[Event(name="FIELD_SELECTED", type="popForm.PopMenuEvent")]
	public class PopMenuContenDisplay extends MovieClip
	{
		private static var stagePlusHaight:Number = 0;
		
		private var myHieghtPlus:Number = 0 ;
		
		
		private var mainText:TextField;
		
		private var mainTextMinHeight:Number ;
		
		private var buttonList:Vector.<PopButton>;
		
		private var field:Vector.<PopFieldInterface> ;
		
		private var myDisplay:DisplayObject ;
		
		private var maxAreaMC:MovieClip ;

		private var scroll:ScrollMT;
		
		private var thisY:Number ;
		
		public var height0:Number; 
		
		private var popFieldType:Class,
					buttonFieldType:Class;
		
		private static var lastScrollY:Number = 0 ;
		
		private var absoluteHeight:Number = NaN ;
		
		public static var showPopBackGroundAsDefault:Boolean = false ;
		
		
		public static var ylist:Number = 10;
		public static var contolBtnY:Number = 20;
		/**Add more Height for scrolling*/
		public function localHeight(H:Number):void
		{
			myHieghtPlus = H ;
		}
		
		public function setY(value:Number):void
		{
			thisY = value ;
			if(scroll)
			{
				scroll.y = value ;
			}
			else
			{
				super.y = value ;
			}
		}
		
		override public function set height(value:Number):void
		{
			absoluteHeight = value ;
		}
		
		/**Returns the content rectangle area*/
		public function getRectArea():Rectangle
		{
			return new Rectangle(maxAreaMC.width/-2,0,maxAreaMC.width,maxAreaMC.height)
		}
		
		public function get contentWidth():Number
		{
			return maxAreaMC.width ;
		}
		
		public function get contentHeight():Number
		{
			return maxAreaMC.height ;
		}
		
		public function PopMenuContenDisplay()
		{
			super();
			
			var samplePopField:PopField = Obj.findThisClass(PopField,this);
			if(samplePopField==null)
			{
				popFieldType = PopField ;
			}
			else
			{
				popFieldType = Obj.getObjectClass(samplePopField);
				Obj.remove(samplePopField);
			}
			var sampleButton:PopButton = Obj.findThisClass(PopButton,this);
			if(sampleButton==null)
			{
				buttonFieldType = PopButton ;
			}
			else
			{
				buttonFieldType =  Obj.getObjectClass(sampleButton);
				SaffronLogger.log("buttonFieldType : "+buttonFieldType);
				Obj.remove(sampleButton);
			}
			
			thisY = this.y ;
			
			maxAreaMC = Obj.get("maxArea_mc",this) ;
			var areaW:Number = maxAreaMC.width;
			var areaH:Number = maxAreaMC.height ;
			maxAreaMC.scaleX = maxAreaMC.scaleY = 1 ;
			maxAreaMC.removeChildren();
			maxAreaMC.graphics.clear();
			maxAreaMC.graphics.beginFill(0);
			//Why areaH/2 ????
			maxAreaMC.graphics.drawRect(areaW/-2,0/*areaH/-2*/,areaW,areaH);
			maxAreaMC.visible = false ;
			
			field = new Vector.<PopFieldInterface>();
			
			mainText = Obj.get('main_txt',this);
			mainTextMinHeight = mainText.height ;
			
			if(!DevicePrefrence.isTablet)
			{
				var txtFormat:TextFormat = mainText.getTextFormat();
				txtFormat.size = txtFormat.size+ylist;
				mainText.defaultTextFormat = txtFormat ;
			}
			mainText.text = '' ;
			
			buttonList = new Vector.<PopButton>();
			
			height0 = this.height ;
		}
		
		public function update(content:PopMenuFields):void
		{
			for(var i:int = 0 ; i<content.fieldDefaults.length ; i++)
			{
				for(var j:int=0 ; j<field.length ; j++)
				{
					if(field[j].title == content.tagNames[i])
					{
						//Update this field;
						if(field[j] is PopFieldDate)
						{
							SaffronLogger.log("Update date");
							field[j].update(content.fieldDefaultDate[i]);
						}
						else
						{
							field[j].update(content.fieldDefaults[i]);
						}
						break;
					}
				}
			}
		}
		
		/**set up the pop menu contents*/
		public function setUp(content:PopMenuContent=null,activateColorDeviderForFieldsBoolean:*=null/*,color:ColorTransform*//*,resetScroll:Boolean=true*/):void
		{
			if(activateColorDeviderForFieldsBoolean==null)
			{
				activateColorDeviderForFieldsBoolean = showPopBackGroundAsDefault ;
			}
			this.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
			
			this.graphics.clear();
			
			while(field.length>0)
			{
				this.removeChild(field[0]);
				field.shift();
			}
			
			if(myDisplay!=null)
			{
				this.removeChild(myDisplay);
				myDisplay = null ;
			}
			
			for(var i:int = 0 ; i<buttonList.length ;i++)
			{
				if(buttonList[i] is DisplayObject)
				{
					this.removeChild(buttonList[i]);
				}
			}
			buttonList = new Vector.<PopButton>();
			
			if(content == null)
			{
				return ;
			}
			if(!content.justify)
			{
				if(StringFunctions.isPersian(content.mainTXT))
					UnicodeStatic.fastUnicodeOnLines(mainText,content.mainTXT,true);
				else
					mainText.text = content.mainTXT;
			}
			else
			{
				if(StringFunctions.isPersian(content.mainTXT))
					UnicodeStatic.htmlText(mainText,content.mainTXT,false,true,true);
				else
					mainText.text = content.mainTXT;
			}
			if(content.displayObject == null)
			{
				mainText.height = Math.max(mainText.height,mainTextMinHeight);
			}
			var Y:Number ;
			if(content.mainTXT=='')
			{
				//☻
				Y = mainText.y;//+10 ;
			}
			else
			{
				Y = mainText.height+mainText.y;
			}
			
			if(content.displayObject!=null)
			{
				myDisplay = content.displayObject ;
				myDisplay.y = Y ;
				myDisplay.x = 0 ;
				this.addChild(myDisplay);
				Y+=myDisplay.height+ylist ;
			}
			
			var deltaYForFiedl:Number = 0 ;
			
			var deltaXForButtons:Number = ylist,
				//☻
				deltaYForButtons:Number = 0;//20;
			
			//SaffronLogger.log('content.haveField : '+content.haveField);
			
			
			
			if(content.haveField)
			{
				for(i = 0 ; i<content.fieldDatas.fieldDefaults.length ; i++)
				{
					var oldY:Number = Y ; 
					//SaffronLogger.log("content.fieldDatas.keyBoards[i] : "+content.fieldDatas.keyBoards[i]);
					switch(content.fieldDatas.popFieldType[i])
					{
						case(PopMenuFieldTypes.CLICK):
						case(PopMenuFieldTypes.RadioButton):
						case(PopMenuFieldTypes.PHONE):
						case(PopMenuFieldTypes.STRING):
						{
							//SaffronLogger.log("It is String field");
							var newfield:PopField = new popFieldType();
							newfield.setUp(
								content.fieldDatas.tagNames[i]
								,content.fieldDatas.fieldDefaults[i]
								,content.fieldDatas.keyBoards[i]
								,content.fieldDatas.isPassWorld[i]
								,content.fieldDatas.editable[i]
								,content.fieldDatas.isArabic[i]
								,content.fieldDatas.numLines[i]
								,content.fieldDatas.backColor[i]
								,content.fieldDatas.languageDirection[i]
								,content.fieldDatas.maxCharacters[i]
								,content.fieldDatas.fieldDefaultBooleans[i]
								,false,false,ReturnKeyLabel.NEXT,selectNextFieldOrNextButton,false
								,content.fieldDatas.multiLineTag[i]
								,content.fieldDatas.justify[i]
								);
							this.addChild(newfield);
							newfield.y = Y ;
							Y+=newfield.height+ylist;
							deltaYForFiedl = ylist;//newfield.height*2 ;
							field.push(newfield) ;
							
							switch(content.fieldDatas.popFieldType[i])
							{
								case(PopMenuFieldTypes.CLICK):
								{
									newfield.mouseChildren = false ;
									newfield.mouseEnabled = true ;
									newfield.buttonMode = true ;
									newfield.addEventListener(MouseEvent.CLICK,clicableFieldSelects);
									break;
								}
								case(PopMenuFieldTypes.RadioButton):
								{
									newfield.mouseChildren = false ;
									newfield.mouseEnabled = true ;
									newfield.buttonMode = true ;
									newfield.addEventListener(MouseEvent.CLICK,newfield.switchRadioButton);
									break;
								}
								case(PopMenuFieldTypes.PHONE):
								{
									newfield.phoneControl = true ;
									break
								}
							}
							
							break;
						}
						case(PopMenuFieldTypes.DATE):
						{
							SaffronLogger.log("add date input field");
							var newfieldDate:PopFieldDate = new PopFieldDate(
								content.fieldDatas.tagNames[i]
								,content.fieldDatas.fieldDefaultDate[i]
								,content.fieldDatas.isArabic[i]
								,content.fieldDatas.languageDirection[i]
								,content.fieldDatas.backColor[i]
							);
							this.addChild(newfieldDate);
							newfieldDate.y = Y ;
							Y+=newfieldDate.height+ylist;
							deltaYForFiedl = ylist;//newfield.height*2 ;
							field.push(newfieldDate) ;
							
							break;
						}
						case(PopMenuFieldTypes.TIME):
						{
							SaffronLogger.log("add Time input field");
							var newfieldTime:PopFieldTime = new PopFieldTime(
								content.fieldDatas.tagNames[i]
								,content.fieldDatas.fieldDefaultDate[i]
								,content.fieldDatas.isArabic[i]
								,content.fieldDatas.languageDirection[i]
								,content.fieldDatas.backColor[i]
							);
							this.addChild(newfieldTime);
							newfieldTime.y = Y ;
							Y+=newfieldTime.height+ylist;
							deltaYForFiedl = ylist;//newfield.height*2 ;
							field.push(newfieldTime) ;
							break;
						}
						case(PopMenuFieldTypes.BOOLEAN):
						{
							SaffronLogger.log("add Boolean input field");
							var newBooleanTime:PopFieldBoolean = new PopFieldBoolean(
								content.fieldDatas.tagNames[i],
								content.fieldDatas.booleanValues[i],
								content.fieldDatas.isArabic[i],
								content.fieldDatas.languageDirection[i],
								content.fieldDatas.backColor[i]
							);
							this.addChild(newBooleanTime);
							newBooleanTime.y = Y ;
							Y+=newBooleanTime.height+ylist;
							deltaYForFiedl = ylist;//newfield.height*2 ;
							field.push(newBooleanTime) ;
							break;
						}
						default:
						{
							throw "This is undefined type of PopMenuField";
						}
					}
					if(activateColorDeviderForFieldsBoolean && (i%2)==0)
					{
						this.graphics.beginFill(0xffffff,0.5);
						this.graphics.drawRect(maxAreaMC.width/-2,oldY,maxAreaMC.width,Y-oldY)
					}
				}
				//Y -= newfield.height ;
			}
			else
			{
				//☻
				deltaYForFiedl = 0;//20 ;
			}
			
			var butY:Number = Y+deltaYForFiedl+deltaYForButtons ;
			
			//SaffronLogger.log("butY1 : "+butY+' : '+Y+'+'+deltaYForFiedl+'+'+deltaYForButtons);
			
			var but:PopButton;
			
			var lastInLineButton:int = -1 ;
			var lastButFrame:uint = 0 ;
			
			for(i = 0 ; i<content.buttonList.length ; i++)
			{
				if(content.buttonList[i] == '')
				{
					butY+=contolBtnY;
					buttonList.push(null);
					continue ;
				}
				
				var butData:PopButtonData ;
				
				if(content.buttonList[i] is PopButtonData)
				{
					butData = content.buttonList[i] as PopButtonData;
					if(butData.buttonFrame==0)
					{
						buttonList.push(null);
						butData.ignoreButtonFrameOnLining = false ;
						butData.singleLine = false ;
						continue;
					}
				}
				
				//I am passing complete buttonData with current function to let it controll all state for it self
				but = new buttonFieldType();
				but.y = butY+but.height/2 ;
				this.addChild(but);
				but.setUp(content.buttonList[i],i,content.buttonsInterface[i],content.buttonList[i],(butData!=null)?butData.buttonImage:null);
				
				Obj.setButton(but,buttonSelected);
				
				buttonList.push(but);
				
				but.y = butY+but.height/2 ;
				
				butY += but.height+ylist ;
				//SaffronLogger.log("lastButFrame == but.currentFrame : "+lastButFrame+" vs "+but.currentFrame);
				if(butData!=null && butData.singleLine)
				{
					if(lastInLineButton == -1)
					{
						//Why??
						//Because this is the first inline button
						//SaffronLogger.log("Pop Button began : "+i);
						lastInLineButton = i ;
					}
					else if(lastButFrame == but.currentFrame || butData.ignoreButtonFrameOnLining)
					{
						var butW:Number = but.width ;
						var menuW:Number = maxAreaMC.width ;
						var lineY:Number = buttonList[lastInLineButton].y ;
						/**This value is allways more than 0*/
						var inLineButtons:uint = i-lastInLineButton+1 ;
						var X0:Number = (menuW-butW)/-2;
						var deltaX:Number = (menuW-butW)/(inLineButtons-1) ;
						//SaffronLogger.log("butW = "+butW+' inLineButtons = '+inLineButtons+' menuW = '+menuW+' >>> '+lastInLineButton);
						if(butW*inLineButtons<menuW)
						{
							//SaffronLogger.log("lastInLineButton : "+lastInLineButton+' buttonList.length : '+buttonList.length);
							for(var k:int = lastInLineButton ; k<buttonList.length && buttonList[k]!=null ; k++)
							{
								//SaffronLogger.log("Manage button "+k);
								buttonList[k].y = lineY ;
								buttonList[k].x = X0 + (k-lastInLineButton)*deltaX ;
							}
							//SaffronLogger.log("This button has problem : "+JSON.stringify(butData));
							butY = lineY+but.height/2+ylist ;
						}
						else
						{
							//SaffronLogger.log("Time to go to next line for : "+i);
							lastInLineButton = i ;
						}
					}
					else
					{
						//SaffronLogger.log("The butoon frame is different");
						lastInLineButton = i ;
					}
					//SaffronLogger.log("lastInLineButton : "+lastInLineButton);
				}
				else
				{
					//Cansel inline buttons
					//SaffronLogger.log("Cansel the inline buttons");
					lastInLineButton = -1 ;
				}
				
				lastButFrame = but.currentFrame ;
			}
			if(content.buttonList.length!=0)
			{
				//Added to prevet page from stop scroll if there are buttons
				butY+=20;
			}
			/*for(i = 0 ; i<content.bigButtonList.length ; i++)
			{
				if(content.bigButtonList[i] == '')
				{
					butY+=20;
					continue ;
				}
				
				but = new PopButton(content.bigButtonList[i],i,1);
				
				Obj.setButton(but,buttonSelected);
				
				buttonList.push(but);
				this.addChild(but);
				but.y = butY ;
				
				butY += but.height+10 ;
				
			}*/
			
			maxAreaMC.scaleY = 1 ;
			
			var scrollHeight:Number = absoluteHeight ;
			
			if(isNaN(scrollHeight))
			{
				scrollHeight = maxAreaMC.height+stagePlusHaight+myHieghtPlus ;
			}
			
			var scrollRect:Rectangle = new Rectangle(this.x-maxAreaMC.width/2,thisY,maxAreaMC.width,scrollHeight) ;
			
			//prevent maxAreaMC to rduce height size
			//maxAreaMC.scaleY = 0 ;
			maxAreaMC.height -= 5 ;
			var areaRect:Rectangle ;
			
			if(butY<=scrollRect.height+ylist)
			{
				areaRect = new Rectangle(maxAreaMC.width/-2,0,maxAreaMC.width,butY);
			}
			else
			{
				SaffronLogger.log("The menu had a scroller, so you are free to add extra area for scrolling.");
				areaRect = new Rectangle(maxAreaMC.width/-2,0,maxAreaMC.width,butY+scrollRect.height/2);
			}
			
			this.graphics.beginFill(0xff0000,0);
			this.graphics.drawRect(areaRect.width/-2,0,areaRect.width,areaRect.height);
			
			//SaffronLogger.log(maxAreaMC.height+' vs '+this.height+' vs '+butY);
			lastScrollY = 0 ;
			if(!content.resetScroll && scroll!=null)
			{
				lastScrollY = this.y ;
			}
			scroll = new ScrollMT(this,scrollRect,areaRect,false,false,content.resetScroll);
			if(!content.resetScroll)
			{
				scroll.setPose(NaN,lastScrollY);
				scroll.stopFloat();
			}
			//SaffronLogger.log("* : this.height:"+this.height+' vs scrollRect.height:'+scrollRect.height);
			if(this.height<=scrollRect.height+ylist)
			{
				scroll.reset();
				scroll.lock();
			}
		}

		private function selectNextFieldOrNextButton(currentField:TextField):void
		{
			var i:int = -1 ;
			for(i = 0 ; i<field.length ; i++)
			{
				var popField:PopField = field[i] as PopField ;
				if(popField != null)
				{
					if(currentField == popField.textField)
					{
						break;
					}
				}
			}
			var selectedFieldIndex:int = i;
			if(selectedFieldIndex!=-1 && selectedFieldIndex<field.length-2)
			{
				if(field[selectedFieldIndex+1] is PopField)
				{
					(field[selectedFieldIndex+1] as PopField).activateKeyBoard();
				}
			}
			else if(buttonList.length>0 && buttonList[0]!=null)
			{
				buttonList[0].select()
			}
		}
		
		
		private function clicableFieldSelects(e:MouseEvent):void
		{
			//SaffronLogger.log("Dispatch selected field");
			var targ:PopField = e.currentTarget as PopField ;
			targ.title;
			targ.data ;
			
			var fieldData:Object = {} ;
			fieldData[targ.title] = targ.data ;
			
			this.dispatchEvent(new PopMenuEvent(PopMenuEvent.FIELD_SELECTED,targ.title,fieldData,targ.title,true));
		}
		
		public function updateScrollheight():void
		{
			SaffronLogger.log("myHieghtPlus : "+maxAreaMC.height+'+'+stagePlusHaight+'+'+myHieghtPlus);
			var scrollRect:Rectangle = new Rectangle(this.x-maxAreaMC.width/2,thisY,maxAreaMC.width,maxAreaMC.height+stagePlusHaight+myHieghtPlus) ;
			var areaRect:Rectangle = new Rectangle(maxAreaMC.width/-2,0,maxAreaMC.width,this.height+ylist) ;
			scroll = new ScrollMT(this,scrollRect,areaRect,true);
			SaffronLogger.log("* : this.height:"+this.height+' vs scrollRect.height:'+scrollRect.height);
			if(this.height<=scrollRect.height+ylist)
			{
				scroll.reset();
				scroll.lock();
			}
		}
		
		/**one of the buttons are selected*/
		private function buttonSelected(e:MouseEvent):void
		{
			var outField:Object = {};
			for(var i:int = 0 ; i<field.length ; i++)
			{
				//SaffronLogger.log("field[i].title : "+field[i].title);
				//SaffronLogger.log("field[i].data : "+field[i].data);
				outField[field[i].title] = field[i].data ;
			}
			this.dispatchEvent(new PopMenuEvent(PopMenuEvent.POP_BUTTON_SELECTED,PopButton(e.currentTarget).ID,outField,PopButton(e.currentTarget).title,false,PopButton(e.currentTarget).buttonData));
		}
		
		/**This will returns all PopFieldInterfaces*/
		public function getFields():Vector.<PopFieldInterface>
		{
			return field.concat();
		}
		
		/**Returns field values*/
		public function getFieldValue(fieldTitle:String):*
		{
			for(var i:int = 0 ; i<field.length ; i++)
			{
				if(field[i].title == fieldTitle)
				{
					return field[i].data ;
				}
			}
			return null ;
		}
		
		public static function addMoreHeight(moreHeight:Number):void
		{
			
			stagePlusHaight = moreHeight ;
		}
	}
}