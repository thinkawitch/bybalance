
#import "IDRoundedCellBackgroundView.h"

@implementation IDRoundedCellBackgroundView

@synthesize borderColor, fillColor, position;

#define ROUND_SIZE 12.f

- (BOOL) isOpaque 
{
    return NO;
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    // Drawing code
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [fillColor CGColor]);
    CGContextSetStrokeColorWithColor(c, [borderColor CGColor]);
    CGContextSetLineWidth(c, 2);
    
    UIColor * separatorColor = [UIColor colorWithRed:70.f/255.f green:70.f/255.f blue:70.f/255.f alpha:1];
    
    if (position == IDTableCellPositionTop) 
    {
        
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 1;
        miny = miny + 1;
        
        maxx = maxx - 1;
        maxy = maxy ;
        
        CGContextMoveToPoint(c, minx, maxy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, miny, maxx, maxy, ROUND_SIZE);
        CGContextAddLineToPoint(c, maxx, maxy);
        
        // Close the path
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);
        
        
        //bottom line, separator
        CGContextSetStrokeColorWithColor(c, [separatorColor CGColor]);
        CGContextSetLineWidth(c, 2);
        CGContextMoveToPoint(c, minx+1, maxy);
        CGContextAddLineToPoint(c, maxx-1, maxy);
        CGContextStrokePath(c);
    } 
    else if (position == IDTableCellPositionBottom) 
    {
        
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 1;
        miny = miny ;
        
        maxx = maxx - 1;
        maxy = maxy - 1;
        
        CGContextMoveToPoint(c, minx, miny);
        CGContextAddArcToPoint(c, minx, maxy, midx, maxy, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, maxy, maxx, miny, ROUND_SIZE);
        CGContextAddLineToPoint(c, maxx, miny);
        // Close the path
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);   
        
        
        
        //top line, separator
        CGContextSetStrokeColorWithColor(c, [separatorColor CGColor]);
        CGContextSetLineWidth(c, 2);
        CGContextMoveToPoint(c, minx+1, miny);
        CGContextAddLineToPoint(c, maxx-1, miny);
        CGContextStrokePath(c);
    } 
    else if (position == IDTableCellPositionMiddle) 
    {
        CGFloat minx = CGRectGetMinX(rect) , maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        
        
        CGContextMoveToPoint(c, minx, miny);
        CGContextAddLineToPoint(c, maxx, miny);
        CGContextAddLineToPoint(c, maxx, maxy);
        CGContextAddLineToPoint(c, minx, maxy);
        CGContextFillPath(c);
        
        minx = minx + 1;
        maxx = maxx - 1;
        
        CGContextMoveToPoint(c, minx, miny);
        CGContextAddLineToPoint(c, minx, maxy);
        CGContextStrokePath(c);
        
        CGContextMoveToPoint(c, maxx, miny);
        CGContextAddLineToPoint(c, maxx, maxy);
        CGContextStrokePath(c);
        
        
        //top line, separator
        CGContextSetStrokeColorWithColor(c, [separatorColor CGColor]);
        CGContextSetLineWidth(c, 1);
        CGContextMoveToPoint(c, minx+1, miny);
        CGContextAddLineToPoint(c, maxx-1, miny);
        CGContextStrokePath(c);
        
        //bottom line, separator
        CGContextSetStrokeColorWithColor(c, [separatorColor CGColor]);
        CGContextSetLineWidth(c, 2);
        CGContextMoveToPoint(c, minx+1, maxy);
        CGContextAddLineToPoint(c, maxx-1, maxy);
        CGContextStrokePath(c);
        
    } 
    else if (position == IDTableCellPositionSingle)
    {
        
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , midy = CGRectGetMidY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 1;
        miny = miny + 1;
        
        maxx = maxx - 1;
        maxy = maxy - 1;
        
        CGContextMoveToPoint(c, minx, midy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, miny, maxx, midy, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, ROUND_SIZE);
        CGContextAddArcToPoint(c, minx, maxy, minx, midy, ROUND_SIZE);
        
        // Close the path
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);      
        
    }
}

/*
// original method
-(void)drawRect:(CGRect)rect 
{
    // Drawing code
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [fillColor CGColor]);
    CGContextSetStrokeColorWithColor(c, [borderColor CGColor]);
    CGContextSetLineWidth(c, 2);
    
    if (position == IDTableCellPositionTop) 
    {
        
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 1;
        miny = miny + 1;
        
        maxx = maxx - 1;
        maxy = maxy ;
        
        CGContextMoveToPoint(c, minx, maxy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, miny, maxx, maxy, ROUND_SIZE);
        CGContextAddLineToPoint(c, maxx, maxy);
        
        // Close the path
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);
        
        return;
    } 
    else if (position == IDTableCellPositionBottom) 
    {
        
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 1;
        miny = miny ;
        
        maxx = maxx - 1;
        maxy = maxy - 1;
        
        CGContextMoveToPoint(c, minx, miny);
        CGContextAddArcToPoint(c, minx, maxy, midx, maxy, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, maxy, maxx, miny, ROUND_SIZE);
        CGContextAddLineToPoint(c, maxx, miny);
        // Close the path
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);        
        return;
    } 
    else if (position == IDTableCellPositionMiddle) 
    {
        CGFloat minx = CGRectGetMinX(rect) , maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 1;
        miny = miny ;
        
        maxx = maxx - 1;
        maxy = maxy ;
        
        CGContextMoveToPoint(c, minx, miny);
        CGContextAddLineToPoint(c, maxx, miny);
        CGContextAddLineToPoint(c, maxx, maxy);
        CGContextAddLineToPoint(c, minx, maxy);
        
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);        
        return;
    } 
    else if (position == IDTableCellPositionSingle)
    {
        
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , midy = CGRectGetMidY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 1;
        miny = miny + 1;
        
        maxx = maxx - 1;
        maxy = maxy - 1;
        
        CGContextMoveToPoint(c, minx, midy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, miny, maxx, midy, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, ROUND_SIZE);
        CGContextAddArcToPoint(c, minx, maxy, minx, midy, ROUND_SIZE);
        
        // Close the path
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);                
        return;         
         
    }
    
   
}
*/

- (void)dealloc 
{
    [borderColor release];
    [fillColor release];
    [super dealloc];
}

@end
