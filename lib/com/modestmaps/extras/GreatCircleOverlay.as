package com.modestmaps.extras
{
    import com.modestmaps.Map;
    import com.modestmaps.core.MapExtent;
    import com.modestmaps.geo.Location;
    
    import flash.display.Sprite;
    //import flash.filters.DropShadowFilter;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    /** 
    * a subclass of overlay that will render dashed great-circle arcs
    */
    public class GreatCircleOverlay extends Overlay
    {        
        public var lines:Array = [];
        private var styles:Dictionary = new Dictionary();
    
        public function GreatCircleOverlay(map:Map)
        {
            super(map);
            //this.filters = [ new DropShadowFilter(2,90,0x000000,0.35,8,8,2,1,false,false,false) ];
        }
        
        override public function redraw(sprite:Sprite):void
        {
            sprite.graphics.clear();
            for each (var line:Array in lines) {
                var lineStyle:LineStyle = styles[line] as LineStyle;
                var p:Point = map.locationPoint(line[0] as Location, sprite);
                sprite.graphics.moveTo(p.x, p.y);
                var i:int = 0;
                var prev:Location;
                for each (var location:Location in line.slice(1)) {
                    var thickness:Number = Math.min(1,1-Math.abs(i-(line.length/2))/(line.length/3));
/*                     if (i % 4 == 0 && i != line.length-1) {
                        sprite.graphics.lineStyle();
                    }
                    else {
                        lineStyle.apply(sprite.graphics, 1+thickness);
                    }            */
                    lineStyle.apply(sprite.graphics, 1+thickness);
                    p = map.locationPoint(location, sprite);
                    if (prev && (Math.abs(prev.lat-location.lat) > 10 || Math.abs(prev.lon-location.lon) > 10)) {
                        sprite.graphics.moveTo(p.x,p.y);
                    }
                    else {
                        sprite.graphics.lineTo(p.x,p.y);
                    }
                    i++;
                    prev = location;
                }
            }
        }
    
        public function addGreatCircle(start:Location, end:Location, lineStyle:LineStyle = null):MapExtent
        {
    
            var extent:MapExtent = new MapExtent();
            var latlngs:Array = [];

			var lat1:Number;
			var lon1:Number;
			var lat2:Number;
			var lon2:Number;
			
			var d:Number;
			var bearing:Number;
			
			var f:Number;
			var A:Number;
			var B:Number;
			var x:Number;
			var y:Number;
			var z:Number;
			
			var latN:Number;
			var lonN:Number;
			
			var n:int;
			var numSegments:int;
			var l:Location;
			
            with (Math) {
                
    			lat1 = start.lat * PI / 180.0;
    			lon1 = start.lon * PI / 180.0;
    			lat2 = end.lat * PI / 180.0;
    			lon2 = end.lon * PI / 180.0;
    			
    			d = 2*asin(sqrt( pow((sin((lat1-lat2)/2)),2) + cos(lat1)*cos(lat2)*pow((sin((lon1-lon2)/2)),2)));
    			bearing = atan2(sin(lon1-lon2)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon1-lon2))  / -(PI/180);
    			bearing = bearing < 0 ? 360 + bearing : bearing;
    
                numSegments = int(40 + (400 * Distance.approxDistance(start,end) / (Math.PI * 2 * 6378000)));
    			for (n = 0 ; n < numSegments; n++ ) {
    				f = (1/(numSegments-1)) * n;
    				a = sin((1-f)*d)/sin(d);
    				b = sin(f*d)/sin(d);
    				x = A*cos(lat1)*cos(lon1) +  B*cos(lat2)*cos(lon2);
    				y = A*cos(lat1)*sin(lon1) +  B*cos(lat2)*sin(lon2);
    				z = A*sin(lat1)           +  B*sin(lat2);
    
    				latN = atan2(z,sqrt(pow(x,2)+pow(y,2)));
    				lonN = atan2(y,x);
    				l = new Location(latN/(PI/180), lonN/(PI/180));
    				latlngs.push(l);
    				extent.enclose(l);
                }
            }
            
            lines.push(latlngs);
            
            styles[latlngs] = lineStyle || new LineStyle();
    
            refresh();
            
            return extent;
        }
        
    }
}
