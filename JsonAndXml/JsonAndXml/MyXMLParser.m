//
//  MyXMLParser.m
//  JSON & XML
//
//  Created by apple on 13-10-10.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MyXMLParser.h"

@interface MyXMLParser() <NSXMLParserDelegate>
{
    // 记录块代码的成员变量
    startElementBlock _startElementBlock;
    endElementBlock _endElementBlock;
    xmlParserNotificationBlock _finishedBlock;
    xmlParserNotificationBlock _errorBlock;
}

// 开始节点名称，例如：video，如果检测到此名称，需要实例化对象
@property (strong, nonatomic) NSString *startElementName;

// 中转字符串
@property (strong, nonatomic) NSMutableString *elementString;

@end

@implementation MyXMLParser

- (void)xmlParserWithData:(NSData *)data
                startName:(NSString *)startName
             startElement:(startElementBlock)startElement
               endElement:(endElementBlock)endElement
           finishedParser:(xmlParserNotificationBlock)finishedParser
              errorParser:(xmlParserNotificationBlock)errorParser
{
    self.startElementName = startName;
    
    // 记录块代码
    _startElementBlock = startElement;
    _endElementBlock = endElement;
    _finishedBlock = finishedParser;
    _errorBlock = errorParser;
    
    // 定义解析器，并且开始解析
    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
    // 设置代理
    [parser setDelegate:self];
    
    // 解析器开始解析
    [parser parse];
}

#pragma mark - XML解析器代理方法
// 所谓需要与外界交互，表示需要与调用方打交道，通知调用方执行某些操作
// 1. 开始解析文档，初始化数据，也不需要与外部交互
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    // 实例化中转字符串
    if (self.elementString == nil) {
        self.elementString = [NSMutableString string];
    }
}

// 2. 开始解析元素（元素的头部video，需要实例化对象，attributeDict需要设置属性）
//  需要与外部交互
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:self.startElementName]) {
        // 开始部分的代码
        _startElementBlock(attributeDict);
    }
    
    // 开始循环执行第3个方法前，清空中转字符串
    [self.elementString setString:@""];
}

// 3. 发现元素字符串(拼接字符串，不需要跟外部交互)
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.elementString appendString:string];
}

// 4. 结束元素解析，根据elementName和第3步的拼接内容，确定对象属性，需要与外部交互
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *result = [NSString stringWithString:self.elementString];
    
    _endElementBlock(elementName, result);
}

// 5. 解析文档结束，通常需要调用方刷新数据（需要与外界交互）
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self.elementString setString:@""];
    
    _finishedBlock();
}

// 6. 解析出错，通知调用方解析出错（需要与外界交互）

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"解析出错");
    [self.elementString setString:@""];
    
    // 带一个NSError回去会更好！
    _errorBlock();
}

@end
