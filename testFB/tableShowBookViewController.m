//
//  tableShowBookViewController.m
//  testFB
//
//  Created by Cyrilshanway on 2014/12/5.
//  Copyright (c) 2014年 Cyrilshanway. All rights reserved.
//

#import "tableShowBookViewController.h"
#import "Book.h"
#import "AFNetworking.h"

@interface tableShowBookViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSInteger iNum;
    NSMutableArray          *_dataSource;
    NSMutableArray          *_imageList;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong )NSMutableArray *isbnArray;
@property (nonatomic, strong) NSDictionary *showThisBookInfoDict;
@property (nonatomic, strong) NSDictionary *tempDict;

@property (nonatomic, strong) NSMutableArray *currentIsbnArray2;
@property (nonatomic, strong) NSMutableArray *currentPicArray2;
@property (nonatomic, strong) NSDictionary   *currrentBookDict2;
@property (nonatomic, strong) NSMutableArray *userAllBookArray2;


@property (nonatomic, strong) NSMutableArray *showPicArray2;
@end

@implementation tableShowBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataSource = [NSMutableArray arrayWithCapacity:0];
    _imageList = [NSMutableArray arrayWithCapacity:0];
    [self getDuReadingURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20.0;
}
//分類
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
//欄位高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}
//要顯示幾個欄位
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _showPicArray2.count;
}
-(NSMutableArray*) isbnArray{
    
    if(!_isbnArray)
        _isbnArray = [[NSMutableArray alloc]init];
    
    return _isbnArray;
}

-(NSDictionary*) showThisBookInfoDict{
    
    if(!_showThisBookInfoDict)
        _showThisBookInfoDict = [[NSDictionary alloc]init];
    
    return _showThisBookInfoDict;
}

-(NSDictionary*) tempDict{
    
    if(!_tempDict)
        _tempDict = [[NSDictionary alloc]init];
    
    return _tempDict;
}

-(NSMutableArray*) currentIsbnArray2{
    
    if(!_currentIsbnArray2)
        _currentIsbnArray2 = [[NSMutableArray alloc]init];
    
    return _currentIsbnArray2;
}

-(NSMutableArray*) currentPicArray2{
    
    if(!_currentPicArray2)
        _currentPicArray2 = [[NSMutableArray alloc]init];
    
    return _currentPicArray2;
}

-(NSMutableArray*) userAllBookArray2{
    
    if(!_userAllBookArray2)
        _userAllBookArray2 = [[NSMutableArray alloc]init];
    
    return _userAllBookArray2;
}

-(NSDictionary*) currrentBookDict2{
    
    if(!_currrentBookDict2)
        _currrentBookDict2 = [[NSDictionary alloc]init];
    
    return _currrentBookDict2;
}

-(NSDictionary*) finalBookDict{
    
    if(!_finalBookDict)
        _finalBookDict = [[NSDictionary alloc]init];
    
    return _finalBookDict;
}

-(NSMutableArray*) showPicArray2{
    
    if(!_showPicArray2)
        _showPicArray2 = [[NSMutableArray alloc]init];
    
    return _showPicArray2;
}



- (void)getDuReadingURL{
    [_dataSource removeAllObjects];
    [_imageList removeAllObjects];

    
    //1. 準備HTTP Client
    //    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
    //                            fb_token,@"fb_token",
    //                            nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://106.185.55.19/"]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:@"api/v1/books" parameters:nil];
    //2.準備operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    //3.準備callback block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Response: %@",tmp);
        
        NSData *rawData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *e1;
        //裝isbn
        NSMutableArray *currentIsbnArray = [[NSMutableArray alloc] init];
        //裝封面(做處理)
        NSMutableArray *currentPicArray = [[NSMutableArray alloc] init];
        //裝個別書資訊
        NSDictionary *currrentBookDict = [[NSDictionary alloc] init];
        //user所有書籍資訊
        //NSMutableDictionary *userAllBookDict = [[NSMutableArray alloc] init];
        NSMutableArray *userAllBookArray = [[NSMutableArray alloc] init];
        
        
        //開始找書吧！
        //1. 先找出user擁有的書
        NSString *user = @"1";
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&e1];
        //NSArray *bookInfo1 = dict[@"books"];
        NSInteger arrayNum = [dict[@"books"] count];
        
        //NSLog(@"%@",dict[@"books"][0][@"id"]);
        
        for (int i = 0; i < arrayNum; i++) {
            //            NSLog(@"i = %d,id: %@", i ,[dict[@"books"][i]objectForKey:@"id"]);
            //            NSLog(@"%@", dict[@"books"]);
            NSLog(@"%@",dict[@"books"][i]);
            
            NSString *stringA = [NSString stringWithFormat:@"%@", [dict[@"books"][i] objectForKey:@"id"]];
            
            if ([user isEqualToString:stringA]) {
                //NSString *isbnString =[dict[@"books"][i] objectForKey:@"isbn"];
                //只存isbn訊息的array
                [currentIsbnArray addObject:[dict[@"books"][i] objectForKey:@"isbn"]];
                //只存pic封面的array
                [currentPicArray addObject:[dict[@"books"][i] objectForKey:@"cover_large_url"]];
                //裝個別書資訊
                currrentBookDict = @{@"author":[dict[@"books"][i] objectForKey:@"author"],
                                     @"cover_large_url":[dict[@"books"][i] objectForKey:@"cover_large_url"],
                                     @"cover_small_url":[dict[@"books"][i] objectForKey:@"cover_small_url"],
                                     @"description":[dict[@"books"][i] objectForKey:@"description"],
                                     @"id":[dict[@"books"][i] objectForKey:@"id"],
                                     @"isbn":[dict[@"books"][i] objectForKey:@"isbn"],
                                     @"pages":[dict[@"books"][i] objectForKey:@"pages"],
                                     @"publish_date":[dict[@"books"][i] objectForKey:@"publish_date"],
                                     @"publisher":[dict[@"books"][i] objectForKey:@"publisher"],
                                     @"title":[dict[@"books"][i] objectForKey:@"title"],
                                     @"user_id":[dict[@"books"][i] objectForKey:@"user_id"],
                                     @"comments":[dict[@"books"][i] objectForKey:@"comments"]
                                     };
                
                //NSLog(@"currrentBookDict: %@", currrentBookDict);
                [userAllBookArray addObject:currrentBookDict];
                //[userAllBookDict setObject:currrentBookDict forKey:isbnString];
                
            }
            
        }
        
        self.userAllBookArray2 = userAllBookArray;
        NSLog(@"currentPicArray: %@",currentPicArray);
        NSLog(@"currrentBookDict: %@",currrentBookDict);
        NSLog(@"currentIsbnArray: %@", currentIsbnArray);
        //user擁有的書的isbn array isbnArray
        self.isbnArray = currentIsbnArray;
        //擁有的書籍數量(首先用途：要產生幾本封面)
        //NSInteger ownerbbookNum = currentIsbnArray.count;
        
        //NSInteger arrayLength = [currentIsbnArray count];
        //先給預設圖片
        //if (arrayLength == 1) {
            for (int i = 0 ; i < currentIsbnArray.count; i++) {
                NSDictionary *innerDict = currentPicArray[i];
                [_dataSource addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [innerDict objectForKey:@"featured_image"],  @"featured_image",
                                        
                                        nil]];
                
                UIImage *image = [UIImage imageNamed:@"background"];
                [_showPicArray2 addObject:image];
            }
        //}
        NSMutableArray *showPicArray = [[NSMutableArray alloc] init];
        
        //pic轉檔
        for (int i =0; i < currentPicArray.count; i++) {
            UIImage *result;
            NSString *imgurlTrans = currentPicArray[i];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgurlTrans]];
            
            result = [UIImage imageWithData:data];
            
            [showPicArray addObject:result];
            
            //NSLog(@"pic: %@", array1[i][@"imageUrl"]);
            //self.backgroundScrollView.imageView.image = result;
        }
        _showPicArray2 = showPicArray;
        
        [self.tableView reloadData];
        //------------------AFImageRequestOperation----------------------//
        //因為不是同步處理照片，接下來往下走就要存照片，那pic的array就是空的，會當掉
        
        //        for (int i = 0 ; i < [currentPicArray count]; i++) {
        //            //NSString *urlStr = [_dataSource[i] objectForKey:@"featured_image"];
        //            NSString *urlString = currentPicArray[i];
        //            NSString *imageRequestURL = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //            NSURL *imageURL = [NSURL URLWithString:imageRequestURL];
        //
        //            AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
        //                [showPicArray addObject:image];
        //                //[showPicArray setObject:image atIndexedSubscript:i];
        //                //[self.tableView reloadData];
        //            }];
        //
        //            NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        //            [queue addOperation:imageOperation];
        //            [imageOperation start];
        //        }
        
        
        //------------------------------------------------//
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"HTTP Error");
    }];
    
    //4. Start傳輸
    [operation start];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.imageView.image = _showPicArray2[indexPath.row];
    
    
    
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
