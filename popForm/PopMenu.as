﻿package popForm
{
	import avmplus.getQualifiedClassName;
	
	import flash.desktop.NativeApplication;
	import flash.display.FocusDirection;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	public class PopMenu extends MovieClip
	{
		private static const CANCEL_ELEMENT_NAME:String = "cancel_mc" ;
		
		/**main object of class*/
		private static var ME:PopMenu;
		
		public var popDispatcher:PopMenuDispatcher = new PopMenuDispatcher();
		
		private static var backButtonName:String ; 
		
		
		/**main textfield from pop menu
		private var mainTXT:TextField;*/
		
		//private var content:PopMenuContenDisplay;
		
		/***/
		private var //titleMC:MovieClip,
					titleBackMC:MovieClip,
					titleTXT:TextField,
					titleCont:MovieClip;
		
		/*private var buttomMC:MovieClip,
					buttomTXT:TextField;*/
					
					
		private var backMC:MovieClip,
					backMinH:Number,
					backMaxH:Number=600;
					
		private var Y0:Number ;
					
					
		private var menuIconMC:MovieClip;
		
		/**this variables tells if this menu is visible or not*/
		public var show:Boolean = false;
					
					
///////////////////////////////////////////////
		/**this class will generate conten input of main from this class*/
		public var myContent:PopMenuContenDisplay ;
		
		private var closeTimer:Timer ;
		private var cashedContents:PopMenuContent;
		private var onButton:Function;
		
		private static var 	cancelNames:Array=[],
							cancelButton:MovieClip,
							cancelEvent:PopMenuEvent;
		
		
		public static function backEnable(backString:String)
		{
			backButtonName = backString ;
		}
		
		/**Activate the static cansel button*/
		public static function staticCanselEnabled(CancelNames:Array):void
		{
			cancelNames = CancelNames.concat() ;
			for(var i = 0 ; i<cancelNames.length ; i++)
			{
				cancelNames[i] = String(cancelNames[i]);
			}
		}
		
		public static function get popDispatcher():PopMenuDispatcher
		{
			return ME.popDispatcher ;
		}
					
		public function PopMenu()
		{
			super();
			ME = this ;
			var cancelButtons:Array = Obj.getAllChilds(CANCEL_ELEMENT_NAME,this); 
			if(cancelButtons.length>0)
			{
				cancelButton = cancelButtons[0];
			}
			if(cancelButton)
			{
				trace("cancelButton is defined");
				cancelButton.addEventListener(MouseEvent.CLICK,cancelSelected);
				cancelButton.buttonMode = true ;
			}
			else
			{
				trace("No global cancel button here");
			}
			
			Y0 = this.y ;
			
			this.addEventListener(Event.ENTER_FRAME,anim);
			this.gotoAndStop(1);
			this.visible = false;
			
			titleCont = Obj.get('title_container',this);
			titleTXT = Obj.get('title_txt',titleCont);
			titleBackMC = Obj.get('title_cont',this);
			//titleMC = Obj.get('title_mc',titleBackMC);
			
			//content = Obj.get('contents_mc',this);
			
			myContent = Obj.findThisClass(PopMenuContenDisplay,this,true);
			myContent.addEventListener(PopMenuEvent.POP_BUTTON_SELECTED,popMenuitemsAreSelected);
			
			backMC = Obj.get('backGround_mc',Obj.get('backGround_mc',this));
			var mainBackMC:MovieClip ;
			
			var backGroundchilds:Array = Obj.getAllChilds('main_back_mc',this);
			//trace("backGroundchilds : "+backGroundchilds);
			if(backGroundchilds.length > 0)
			{
				mainBackMC = backGroundchilds[0] ;
			}
			
			if( mainBackMC != null )
			{
				mainBackMC.addEventListener(MouseEvent.CLICK,backClicked);
			}
			else
			{
				trace('main_back_mc is not definds');
			}
			
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN,checkBack);
			
			backMinH = backMC.height ;
			
			menuIconMC = Obj.get('icon_mc',this);
			menuIconMC.stop();
		}
		
		
		/**back button on key board pressed*/
		private function checkBack(ev:KeyboardEvent):void
		{
			// TODO Auto-generated method stub
			if(ev.keyCode == Keyboard.BACK || ev.keyCode == Keyboard.BACKSPACE )
			{
				var controll:Boolean = backClicked(null);
				//trace("FocusDirection : "+FocusDirection);
				//trace("(stage as Stage).focus : "+(stage as Stage).focus);
				
				if(show)
				{
					ev.preventDefault();
					ev.stopImmediatePropagation();
				}
			}
		}
		
		protected function backClicked(event:MouseEvent):Boolean
		{
			// TODO Auto-generated method stub
			//trace("show : "+show);
			if(show)
			{
				trace("Back ground clicked");
				if(backButtonName==null)
				{
					trace( "back button dose not work" ) ;
				}
				for(var i = 0 ; i<cashedContents.buttonList.length ; i++)
				{
					if(cashedContents.buttonList[i] == backButtonName)
					{
						popMenuitemsAreSelected(new PopMenuEvent(PopMenuEvent.POP_BUTTON_SELECTED,i,null,backButtonName));
						trace('back button selected');
						return true;
					}
				}
				trace('no back button avaliable');
			}
			else
			{
				trace("Pop menu is lock");
			}
			return false ;
		}		
		
		
		/**pop menu icons are selected , now it is time to pass it to dispatcher*/
		private function popMenuitemsAreSelected(e:PopMenuEvent)
		{
			this.close();
			var buttonEvent:PopMenuEvent = new PopMenuEvent(e.type,e.buttonID,e.field,e.buttonTitle) ;
			if(onButton!=null)
			{
				onButton(buttonEvent);
			}
			popDispatcher.dispatchEvent(buttonEvent);
		}
		
		
		/**pop the menu up*/
		public static function popUp(title:String='' , type:PopMenuTypes=null , content:PopMenuContent=null,closeOnTime:uint=0)
		{
			trace('POP MENU OPENED '+Math.random());
			ME.popUp2(title, type, content,closeOnTime);
		}
		
		/**close the menu*/
		public static function close()
		{
			ME.close();
		}
		
		/**Close*/
		public function close()
		{
			this.show = false ;
			if(this.currentFrame == 1)
			{
				this.gotoAndStop(2);
			}
		}
		
		/**this will tell if the popMenuIsOpen*/
		public static function get isOpen():Boolean
		{
			return ME.show ;
		}
		
		
		
		/**pop the pop menu up*/
		public function popUp2(title:String='' , type:PopMenuTypes=null , content:PopMenuContent=null,closeOnTime=0,onButtonSelects:Function=null)
		{	
			cashedContents = content ;
			
			onButton = onButtonSelects ;
			
			if(closeTimer!=null)
			{
				closeTimer.stop();
			}
			if(closeOnTime != 0)
			{
				closeTimer = new Timer(closeOnTime,1);
				closeTimer.addEventListener(TimerEvent.TIMER_COMPLETE,closeME);
				closeTimer.start();
			}
			if(type==null)
			{
				type = PopMenuTypes.DEFAULT ;
			}
			
			
			show = true ;
			this.visible = true ;
			
			TextPutter.OnButton(titleTXT,title,true,true,false,false);
			if( titleTXT.height > 600 )
			{
				titleTXT.height = 600 ;
			}
			
			menuIconMC.gotoAndStop(type.frame) ;
			
			//SoundManager.sound_popMenu_ba(type.soundID);
			
			//SoundManager.sound_popMenu();
			
			//titleMC.transform.colorTransform = type.colorTransform ;
			
			/**do not change the form position*/
			//ME.y = Y0-(backMC.height-backMinH)/2;
			
			myContent.setUp(content/*,type.colorTransform*/);
			backMC.height = Math.max(Math.min(myContent.height+50,backMaxH),backMinH) ;//backMinH+Math.floor(Math.random()*(backMaxH-backMinH));
			//trace("myContent.height : "+myContent.height + ' vs backMaxH : '+backMaxH+' vs backMinH : '+backMinH+' > '+backMC.height);
			
			if(cancelButton)
			{
				cancelEvent = null ;
				cancelButton.visible = false ;
				for(var i = 0 ; i<content.buttonList.length ; i++)
				{
					var button:* = content.buttonList[i] ;
					//trace("button : "+button);
					//trace("button is : "+getQualifiedClassName(button));
					var buttonName:String ;
					var buttonId:String ;
					if(button is PopButtonData)
					{
						//trace("This is data button");
						buttonName = (button as PopButtonData).title ;
						buttonId = (button as PopButtonData).id ;
					}
					else
					{
						//trace("This is the string button");
						buttonName = buttonId = String(button) ;
					}
					//trace("cancelNames : "+cancelNames);
					//trace("buttonName : "+buttonName);
					//trace(" cancelNames.indexOf(buttonName) : "+ cancelNames.indexOf(buttonName));
					if( cancelNames.indexOf(buttonName)!=-1)
					{
						cancelButton.visible = true ;
						cancelEvent = new PopMenuEvent(PopMenuEvent.POP_BUTTON_SELECTED,buttonId,null,buttonName) ;
					}
				}
			}
		}
		
		private function cancelSelected(e:MouseEvent):void
		{
			this.close();
			this.dispatchEvent(cancelEvent);
		}
		
		
		/**this function will close pop menu after requested time on popUp function*/
		private function closeME(e:TimerEvent)
		{
			close();
		}
		
///////////////////////////////////////////pop menu manager
		
		/**pop menu magaer*/
		private function anim(e:Event)
		{
			if(show)
			{
				if(this.currentFrame==this.totalFrames-1)
				{
					popDispatcher.dispatchEvent(new PopMenuEvent(PopMenuEvent.POP_SHOWS));
				}
				this.nextFrame();
			}
			else
			{
				for(var i = 0 ; i<3 ; i++)
				{
					if(this.currentFrame==2)
					{
						this.visible =false;
						popDispatcher.dispatchEvent(new PopMenuEvent(PopMenuEvent.POP_CLOSED));
						myContent.setUp();
					}
					this.prevFrame();
				}
			}
		}
	}
}