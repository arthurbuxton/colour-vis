//
//  WKSPieChart.m
//  Colour Vis
//
//  Created by Matt Patterson on 11/07/2013.
//  Copyright (c) 2013 Matt Patterson. All rights reserved.
//

#import "WKSPieChart.h"

@implementation WKSPieChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setColourFreqDict:(id)colourFreqDict {
    _colourFreqDict = colourFreqDict;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [self drawPie];
}

- (void)drawPie {
    if (self.colourFreqDict == nil) return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // set up
    CGContextSetLineWidth(context, 2.0);

    // box (chart extent) setup
    CGFloat inset = 10.0;
    CGFloat bounds = fminf(self.bounds.size.width, self.bounds.size.height);
    CGRect box = CGRectMake(0, 0, bounds, bounds);
    box = CGRectInset(box, inset, inset);
    
    // GO!
    NSArray *top20Keys = [self top:20 keysFromDictionary:self.colourFreqDict];

    // angles setup
    CGFloat radiansPerPixel = (2 * M_PI) / [self sum:self.colourFreqDict usingKeys:top20Keys];
//    NSLog(@"radiansPerPixel: %f", radiansPerPixel);
    __block CGFloat startAngle = 0.0;
    
//    for (NSString *hexColor in [top20Keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
    for (NSString *hexColor in top20Keys) {
        NSNumber *size = [self.colourFreqDict objectForKey:hexColor];
        NSUInteger r;
        NSUInteger g;
        NSUInteger b;
        sscanf([hexColor UTF8String], "%x.%x.%x", &r, &g, &b);
        CGFloat components[4];
        components[0] = r/255.0;
        components[1] = g/255.0;
        components[2] = b/255.0;
        components[3] = 1.0;
        CGColorRef color = CGColorCreate(colorSpace, components);
        
        CGFloat radians = [size integerValue] * radiansPerPixel;
        CGFloat endAngle = startAngle - radians;
        [self drawSliceOfColor:color fromStart:startAngle toEnd:endAngle inBox:box withContext:context];
        startAngle = endAngle;
//        NSLog(@"%@, %@", hexColor, size);
    };
}

- (NSArray*)top:(NSUInteger)number keysFromDictionary:(NSDictionary*)colorFreqDict {
    NSArray *sortedKeys = [colorFreqDict keysSortedByValueUsingSelector:@selector(compare:)];
//    NSLog(@"%@", sortedKeys);
//    NSLog(@"%@", [[sortedKeys reverseObjectEnumerator] allObjects]);
//    NSLog(@"%@", [[[sortedKeys reverseObjectEnumerator] allObjects] subarrayWithRange:NSMakeRange(0, number)]);
    return [[[sortedKeys reverseObjectEnumerator] allObjects] subarrayWithRange:NSMakeRange(0, number)];
}

- (NSUInteger)sum:(NSDictionary*)colorFreqDict usingKeys:(NSArray*)keys {
    NSUInteger total = 0;
    for (NSString *key in keys) {
        total += [[colorFreqDict objectForKey:key] integerValue];
    }
    return total;
}

- (void)drawSliceOfColor:(CGColorRef)color fromStart:(float)startAngle toEnd:(float)endAngle inBox:(CGRect)box withContext:(CGContextRef)context {
    CGFloat midX = CGRectGetMidX(box);
    CGFloat midY = CGRectGetMidY(box);
    CGFloat radius = box.size.width/2;

    // CGFloat correctedValue = value == 1 ? 0.999999 : value;
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetFillColorWithColor(context, color);
    CGContextMoveToPoint(context, midX, midY);
    CGContextAddArc(context, midX, midY, radius, startAngle, endAngle, true);
    CGContextFillPath(context);
//    NSLog(@"%f -> %f", startAngle, endAngle);
}

//- (void)drawValue {
//    if (self.value == 0) return;
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGMutablePathRef path = [self createArcPathWithValue:self.value inset:0];
//    CGContextAddPath(context, path);
//    [[THStyleSheet colorForScore:self.value] setFill];
//    CGContextFillPath(context);
//    
//    CGContextAddPath(context, path);
//    CGContextClip(context);
//    CGPathRelease(path);
//    
//    // Draw a linear gradient from top to bottom
//    UIColor* startColor = [UIColor colorWithWhite:1 alpha:0.2];
//    UIColor* endColor = [UIColor colorWithWhite:0 alpha:0.2];
//    CGColorRef colorRef[] = { startColor.CGColor, endColor.CGColor };
//    CFArrayRef colors = CFArrayCreate(NULL, (const void**)colorRef, sizeof(colorRef) / sizeof(CGColorRef), &kCFTypeArrayCallBacks);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
//    CFRelease(colorSpace);
//    CFRelease(colors);
//    
//    CGPoint start = CGPointMake(0, 0);
//    CGPoint end = CGPointMake(self.bounds.size.width, 0);
//    
//    CGContextDrawLinearGradient(context, gradient, start, end, 0);
//    CFRelease(gradient);
//}
//
//- (void)drawHistoryValue {
//    if (self.historyValue == 0)  return;
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGMutablePathRef historyPath = [self createArcPathWithValue:self.historyValue inset:10];
//    CGContextAddPath(context, historyPath);
//    [[THStyleSheet lightGreyColor] setFill];
//    CGContextFillPath(context);
//    CGPathRelease(historyPath);
//}
//
//- (CGMutablePathRef)createArcPathWithValue:(float)value inset:(CGFloat)inset {
//    CGFloat size = fminf(self.bounds.size.width, self.bounds.size.height);
//    CGRect box = CGRectMake(0, 0, size, size);
//    box = CGRectInset(box, inset, inset);
//    CGFloat midX = CGRectGetMidX(box);
//    CGFloat midY = CGRectGetMidY(box);
//    CGFloat maxY = CGRectGetMaxY(box);
//    CGFloat radius = box.size.width/2;
//    
//    CGMutablePathRef path = CGPathCreateMutable();
//    
//    CGFloat correctedValue = value == 1 ? 0.999999 : value;
//    CGFloat startAngle = (CGFloat) (M_PI_2 - (2* M_PI*(1-correctedValue)));
//    CGPathAddArc(path, NULL, midX, midY, radius, startAngle, (CGFloat) M_PI_2, true);
//    CGPathAddLineToPoint(path, NULL, midX, maxY - self.thickness);
//    CGPathAddArc(path, NULL, midX, midY, radius - self.thickness, (CGFloat) M_PI_2, startAngle, false);
//    CGPathCloseSubpath(path);
//    return path;
//}
//

@end
