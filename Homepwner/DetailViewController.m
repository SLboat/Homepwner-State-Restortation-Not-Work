//
//  DetailViewController.m
//  Homepwner
//
//  Created by Sen on 6/27/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import "DetailViewController.h"
#import "Item.h"
#import "ImageStore.h"
#import "ItemStore.h"
#import "PopoverViewBackGround.h"
#import "AssetTypeViewController.h"

/**< 某个奇怪的东西-十字线 */
@interface CrosshairView : UIView

@end

@implementation CrosshairView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //设置基本信息
        self.backgroundColor = [UIColor clearColor]; //背景透明
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGPoint midPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    //开始画横线
    UIBezierPath *crossHair = [UIBezierPath bezierPath];
    [crossHair moveToPoint:CGPointMake(midPoint.x - 15, midPoint.y)]; //直线左
    [crossHair addLineToPoint:CGPointMake(midPoint.x + 15, midPoint.y)]; //直线右
    [crossHair setLineWidth:2.0];
    //开始画竖线
    [crossHair moveToPoint:CGPointMake(midPoint.x, midPoint.y - 15)]; //离开线条
    [crossHair addLineToPoint:CGPointMake(midPoint.x, midPoint.y + 15)];
    [crossHair stroke];
}

@end

@interface DetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property(nonatomic, weak) IBOutlet UIBarButtonItem *cameraButton;
@property(strong, nonatomic) UIPopoverController *imagePickerPopover;  /**< 弹出框 */

@property(weak, nonatomic) IBOutlet UILabel *nameLabel;
@property(weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property(weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *assetTypeButton;

@end

@implementation DetailViewController

- (instancetype)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        self.restorationIdentifier = NSStringFromClass(self.class); //赋予定义
        self.restorationClass = self.class; //赋予类
        
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem; //赋予它

            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
        //这个的确不是在isNew的快儿代码里..
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }

    return self;
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
}

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)cancel:(id)sender
{
    //如果用户取消了,然后删除这个Item从store
    [[ItemStore sharedStore] removeItem:self.item];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)updateFonts
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    self.nameLabel.font = font;
    self.serialNumberLabel.font = font;
    self.valueLabel.font = font;
    self.dateLabel.font = font;
    self.nameField.font = font;
    self.serialNumberField.font = font;
    self.valueField.font = font;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"错误的初始化器" reason:@"使用initForNewItem" userInfo:nil];
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *iv = [[UIImageView alloc] initWithImage:nil];

    // The contentMode of the image view in the XIB was Apect Fit
    iv.contentMode = UIViewContentModeScaleAspectFit; //方式

    // Do not produce a translated constraint for this view
    iv.translatesAutoresizingMaskIntoConstraints = NO;

    // The image view was a subview of the view
    [self.view addSubview:iv];

    // The image view was pointed to by the imageView property
    self.imageView = iv;

    // 设置竖直的优先级低于或者少于其他子视图的.
    [self.imageView setContentHuggingPriority:200 forAxis:UILayoutConstraintAxisVertical]; //拥抱是200,默认是251,和label一样
    [self.imageView setContentCompressionResistancePriority:700 forAxis:UILayoutConstraintAxisVertical]; //阻碍是700,默认750

    NSDictionary *nameMap = @{@"imageView":self.imageView,
                              @"dateLabel":self.dateLabel,
                              @"toolbar":self.toolbar}; //映射的地图

    // 两边都是0 - 哈,不可怕
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|" options:0 metrics:nil views:nameMap];

    //NSLayoutConstraint *imgLeft = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]; //建立一条左边到左边的约束起来
    //NSLayoutConstraint *imgRight = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]; //另一条约束


    // 8个坐标和上面和下面
    NSArray *verticalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dateLabel]-[imageView]-[toolbar]" options:0 metrics:nil views:nameMap];

    [self.view addConstraints:horizontalConstraints];
    [self.view addConstraints:verticalConstraint];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated]; //上级优先...

    //旋转处理
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];

    Item *item = self.item;

    self.nameField.text = item.itemName;
    self.serialNumberField.text = item.serialNumber;
    self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];

    // You need an nsDateFormatter that will trun a date into a simple date string static
    static NSDateFormatter *dateFormattre = nil;
    if (!dateFormattre) {
        dateFormattre = [[NSDateFormatter alloc] init];
        dateFormattre.dateStyle = NSDateFormatterMediumStyle;
        dateFormattre.timeStyle = NSDateFormatterNoStyle;
    }

    self.dateLabel.text = [dateFormattre stringFromDate:item.dateCreated];

    NSString *imageKey = item.itemKey;

    // Get the iamge for its image key from the image store
    UIImage *imageToDisplay = [[ImageStore sharedStore] imageForKey:imageKey];

    // Uset that image to put on the screen in the imageView
    self.imageView.image = imageToDisplay;

    NSString *typeLabel = [self.item.assetType valueForKey:@"Label"];
    if (!typeLabel) {
        typeLabel = @"无";
    }
    
    self.assetTypeButton.title = [NSString stringWithFormat:@"类型: %@", typeLabel];
    
    [self updateFonts];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // clear first responder
    [self.view endEditing:YES];

    // "Save" changes to item
    Item *item = self.item;
    item.itemName = self.nameField.text;
    item.serialNumber = self.serialNumberField.text;
    item.valueInDollars = [self.valueField.text intValue];
}

- (void)setItem:(Item *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (IBAction)cancelInput:(id)sender
{
    [self.view endEditing:YES];

    //随机触发冲突
    for (UIView *subview in self.view.subviews) {
        if (subview.hasAmbiguousLayout) {
            //[subview exerciseAmbiguityInLayout];
        }
    }
}

- (IBAction)takePicture:(id)sender
{
    if ([self.imagePickerPopover isPopoverVisible]) {
        //如果已经出现了弹出框,驾驭它
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

    imagePicker.allowsEditing = YES;// 铜牌挑战 - 编辑图片

    // If the device has a camera,take a picture,otherewise,
    // just pick from photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CGRect overViewRect = self.view.bounds;
        overViewRect.size.height -= 72; //削掉一些.
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera; //必须先设置类型...才能下面的操作..
        imagePicker.cameraOverlayView = [[CrosshairView alloc] initWithFrame:overViewRect]; //从自身的框架里建立起子试图
        imagePicker.showsCameraControls = YES;//控制器

    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    imagePicker.delegate = self; //委托:它很重要

    //放置图片选择器在屏幕上
    //首先检查是不是iPad设备,在实例化这个弹出玩意之前
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {

        // 创建弹出窗口来显示文件选择器
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        self.imagePickerPopover.delegate = self;

        self.imagePickerPopover.popoverBackgroundViewClass = [PopoverViewBackGround class];

        //显示这个弹出窗口,发送者是图片按钮
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        /* 弹出来的方式 */
        // Place iamge picker on the screen
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

//银牌挑战:删除图片
- (IBAction)removePicture:(id)sender
{
    NSString *imageKey = self.item.itemKey;
    [[ImageStore sharedStore] deleteImageForKey:imageKey];
    self.imageView.image = nil;
}

#pragma mark - 图片选择器完成的委托
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];

    //设置缩略图
    [self.item setThumbnailFromImage:image];

    // Store the image in the ImageStore for this key
    [[ImageStore sharedStore] setImage:image forKey:self.item.itemKey];

    // Put the iamge onto the screen in our image view
    self.imageView.image = image;

    //我有一个弹出框吗?
    if (self.imagePickerPopover) {
        //消除它
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    } else {
        // Take image picker off the screen -
        // you must call this dismiss method
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 调试自动布局g
- (void)viewDidLayoutSubviews
{
    for (UIView *subview in self.view.subviews) {
        if (subview.hasAmbiguousLayout) {
            NSLog(@"发生了冲突: %@", subview);
        }
    }
}

#pragma mark - 旋转世界
- (void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation
{
    // Is it an iPad? No preparation necessary → 是帕子的话,不必要准备.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return; //再见
    }

    // 现在是phone了
    if (UIInterfaceOrientationIsLandscape(orientation)) { //横向的话,一个判断
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    } else {
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self prepareViewsForOrientation:toInterfaceOrientation]; //这里有个to的参数名...
}

#pragma mark -  弹出框委托
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"用户消除了弹出框");
    self.imagePickerPopover = nil;
}

#pragma mark -
#pragma mark 选择类别
- (IBAction)showAssetTYpePicker:(id)sender {
    [self.view endEditing:YES];
    
    AssetTypeViewController *avc = [[AssetTypeViewController alloc]init];
    avc.item = self.item;
    
    [self.navigationController pushViewController:avc animated:YES];
}

#pragma mark -
#pragma mark 状态恢复
//问候要如何恢复
+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    NSLog(@"详细视图恢复路径: %@", identifierComponents);
    BOOL isNew = NO;
    if ([identifierComponents count] == 3) { //如果有三层路径,那就是新建的...原因是它是不存在的,需要跳出来,否则是直接渲染出来的..
        isNew = YES;
    }
    
    //最主要得到发变化的不会显示那个Done按钮
    return [[self alloc]initForNewItem: isNew];
}


- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.item.itemKey forKey:@"item.itemKey"]; //编码自己的属性
    
    // 保存改变到里面
    self.item.itemName = self.nameField.text;
    self.item.serialNumber = self.serialNumberField.text;
    self.item.valueInDollars = [self.valueField.text intValue];
    
    //保存到硬盘
    [[ItemStore sharedStore]saveChanges];
    
    [super encodeRestorableStateWithCoder:coder]; //让父类工作去
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    NSString *itemKey = [coder decodeObjectForKey:@"item.itemKey"];
    for (Item *item in [[ItemStore sharedStore]allItems]){
        if ([itemKey isEqualToString:item.itemKey]) {
            self.item = item;
            break;
        }
    }
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
