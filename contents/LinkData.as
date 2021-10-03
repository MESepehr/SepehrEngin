﻿package contents
{
	import appManager.event.AppEventContent;

	public class LinkData
	{
		/**some links can have submenu on them*/
		public var subLinks:Vector.<LinkData> ;
		
		/**You can enter any value that you need to use on the LinkManagers but it will not export and import on xml*/
		public var dynamicData:Object ;
		
		public var 	name:String='',
					id:String='',
					iconURL:String='',
					iconURL2:String='';
					
		/**if level is -1 , it will add to curren page , if level is 0 , it is the page from main menu<br>
		 * New Level defined: -2 means this page had to replace with current page on history*/
		public var level:int;
		
		/**You can use them for icon size*/
		public var w:Number,h:Number;
		
		public var x:Number,y:Number;
					
		/*<link level="" name="فعالیت های عملی" id="faaliathayeamali" icon="sf.jpg"/>*/
		public function LinkData(linkXML:XML=null)
		{
			subLinks = new Vector.<LinkData>();
			//I add -1 as defaulte level value here
			level = -1 ;
			
			if(linkXML!=null)
			{
				//SaffronLogger.log('each link is : '+linkXML.@level+' - '+linkXML.@name);
				name = linkXML.@name;
				w = Number(linkXML.@w);
				h = Number(linkXML.@h);
				x = Number(linkXML.@x);
				y = Number(linkXML.@y);
				id = linkXML.@id ;
				iconURL = linkXML.@icon ;
				iconURL2 = linkXML.@icon2 ;
				if(String(linkXML.@level) == '')
				{
					level = -1 ;
				}
				else
				{
					level = uint(linkXML.@level);
				}
				//SaffronLogger.log('level is : '+level);
				if(linkXML!='')
				{
					if(linkXML.link != undefined)
					{
						for(var i:int = 0 ; i<linkXML.link.length() ; i++)
						{
							var newLink:LinkData = new LinkData(linkXML.link[i]) ;
							subLinks.push(newLink) ;
						}
					}
				}
			}
		}

		/**
		 * This function will create PageChange event
		 * @return 
		 */
		public function event(skipHistory:Boolean=false,reload:Boolean=false):AppEventContent
		{
			return new AppEventContent(this,skipHistory,reload)
		}

		/**
		 * You can pass String or PageData for the pageData param
		 * @param pageData 
		 * @param dynamicData 
		 * @param level 
		 * @return 
		 */
		public function createLinkFor(pageData:*,dynamicData:Object=null,level:int=-1,name:String=''):LinkData
		{
			if(pageData is PageData)
			{
				id = pageData.id;
			}
			else if(pageData==null)
			{
				id = '' ;
			}
			else
			{
				id = pageData.toString();
			}
			this.dynamicData = dynamicData;
			this.level = level ;
			this.name = name ;
			return this ;
		}
		
		/**export the link*/
		public function export():XML
		{
			var xml:XML = new XML("<link/>");
			xml.@level = level.toString();
			xml.@name = name ;
			xml.@id = id;
			xml.@icon = iconURL;
			xml.@icon2 = iconURL2;
			xml.@w = w;
			xml.@h = h;
			xml.@x = x;
			xml.@y = y;
			
			for(var i:int = 0 ; i<subLinks.length ; i++)
			{
				xml['link'][i] = subLinks[i].export();
			}
			
			//Add export for sublink here
			
			return xml ;
		}
		
		/**Clone the link*/
		public function clone():LinkData
		{
			//return new LinkData(this.export()) ;
			
			//new method for clone
			var newLinkData:LinkData = new LinkData();
			
			for(var i:int = 0 ; i<subLinks.length ; i++)
			{
				newLinkData.subLinks[i] = subLinks[i].clone();
			}
			
			newLinkData.name = name ;
			newLinkData.id = id ;
			newLinkData.iconURL = iconURL ;
			newLinkData.iconURL2 = iconURL2 ;
			newLinkData.level = level ;
			newLinkData.dynamicData = dynamicData ;
			newLinkData.w = w ;
			newLinkData.h = h ;
			newLinkData.x = x ;
			newLinkData.y = y ;
			
			return newLinkData ;
		}
	}
}
