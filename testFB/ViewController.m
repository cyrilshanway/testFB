//
//  ViewController.m
//  testFB
//
//  Created by Cyrilshanway on 2014/11/23.
//  Copyright (c) 2014年 Cyrilshanway. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"
#import "Book.h"

@interface ViewController ()
{
    NSInteger iNum;
}
@property (weak, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (nonatomic, strong )NSMutableArray *isbnArray;
@property (nonatomic, strong) NSDictionary *showThisBookInfoDict;
@property (nonatomic, strong) NSDictionary *tempDict;

@property (nonatomic, strong) NSMutableArray *currentIsbnArray2;
@property (nonatomic, strong) NSMutableArray *currentPicArray2;
@property (nonatomic, strong) NSDictionary   *currrentBookDict2;
@property (nonatomic, strong) NSMutableArray *userAllBookArray2;


@property (nonatomic, strong) NSMutableArray *showPicArray2;
@property Book *myBook;
@end

@implementation ViewController
//#define duReadingURL http://106.185.55.19/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [FBAppEvents activateApp];
//    
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.center = self.view.center;
//    [self.view addSubview:loginView];
    
    
    NSString *access_token = [FBSession activeSession].accessTokenData.accessToken;
    NSLog(@"access_token: %@", access_token);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:access_token forKey:@"access_token"];
    
    [defaults synchronize];
    
    //[self getDuReadingURL];
    
    [self loadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (void)loadData{
    //1. 準備HTTP Client
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://106.185.55.19/"]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *access_token = [defaults objectForKey:@"access_token"];

    
    
    //11/28
    //NSString *token = fb_token;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            access_token,@"access_token",
                            nil];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@"api/v1/login"
                                                      parameters:params];//dictionary
    //2.準備operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    //3.準備callback block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
#pragma mark - progressed 完成
        //載入完成
        
        
        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //test log
        NSLog(@"Response: %@",tmp);
        
        
#pragma mark - 轉資料11/26
        
        //Generate NSDictionary
        NSData *rawData = [tmp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *e1;
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingMutableContainers error:&e1];
        
        //Generate JSON data(11/28)想要存在local端
        NSError *e2;
        NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&e2];
        NSLog(@"json data: %@",jsondata);
        
        //抓auth_token
        
        
        
        NSString *tmp_auth = [dict objectForKey:@"auth_token"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         [defaults setObject:tmp_auth forKey:@"auth_token"];
        
        //step.4
        [self getDuReadingURL];
                
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error");
    }];
    
    //4. Start傳輸
    [operation start];
}






- (void)getDuReadingURL{
    //1. 準備HTTP Client
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *auth_token = [defaults objectForKey:@"auth_token"];
    
    
    //NSString *auth_token = fb_token;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            auth_token,@"auth_token",
                            nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://106.185.55.19/"]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:@"api/v1/books"
                                                      parameters:params];
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
        
        //Generate JSON data(11/28)想要存在local端
        NSError *e2;
        NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&e2];
        NSLog(@"json data: %@",jsondata);
        
        
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
        
        
        
        NSMutableArray *showPicArray = [[NSMutableArray alloc] init];
        
        NSMutableArray *imageList = [NSMutableArray arrayWithCapacity:self.isbnArray.count];
        NSMutableArray *buttonList= [NSMutableArray arrayWithCapacity:self.isbnArray.count];
        
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
        for (int i = 0 ; i < currentIsbnArray.count; i++) {
            
            NSInteger x = 40;
            NSInteger y1 = 46;
            NSInteger y = 0;
            //NSInteger w = 40;
            NSInteger h = 100;//height
            NSInteger g = 40;//間隔
            
            if( (i % 2) == 0) {
                x = 49;
                y = y1 + 0.5*( h + g )* (i-1);
            }
            else {
                x = 220;
                y = y1 + 0.5*( h + g )* (i-2);
            }
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 34, 98)];
            [bgView setBackgroundColor:[UIColor grayColor]];
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 98)];
            
            //[imageView setImage:[UIImage imageNamed:[imageArray2 objectAtIndex:i]]];
            //imageView.image = [imageArray2 objectAtIndex:i];
            //先試試都放default
            imageView.image = [showPicArray objectAtIndex:i];
            
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [bgView addSubview:imageView];
                        
            [imageList addObject:bgView];
            
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(x+5, y+5, 90, 110)];
            button.backgroundColor = [UIColor grayColor];
            
            button.alpha = 1;
            [buttonList addObject:button];
            [button setTag:i];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.backgroundScrollView addSubview:bgView];
            [self.backgroundScrollView addSubview:button];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"HTTP Error");
    }];
    
    //4. Start傳輸
    [operation start];

}

-(void)buttonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;

    NSInteger aNum = button.tag;
    
    _finalBookDict = _userAllBookArray2[aNum] ;
    
    Book *myNewBook = [[Book alloc] init];
    
    myNewBook.descriptionBook = _finalBookDict[@"description"];
    myNewBook.owner = [NSString stringWithFormat:@"%@", _finalBookDict[@"id"]];
    myNewBook.bookCommentArray = _finalBookDict[@"comments"];
    myNewBook.pageNum = [NSString stringWithFormat:@"%@", _finalBookDict[@"pages"]];
    myNewBook.bookPublished = _finalBookDict[@"publish_date"];
    myNewBook.name = _finalBookDict[@"author"];
    myNewBook.ISBNNum = _finalBookDict[@"isbn"];
    myNewBook.title = _finalBookDict[@"title"];
    myNewBook.bookPublisher = _finalBookDict[@"publisher"];
    myNewBook.imageAuthor = _showPicArray2[aNum];
    
    UIImageView *imv = [[UIImageView alloc] initWithImage:myNewBook.imageAuthor];
    
    NSLog(@"%@",[ myNewBook.bookCommentArray[0] objectForKey:@"id"]);
    
    
    _myBook = myNewBook;
}

@end
