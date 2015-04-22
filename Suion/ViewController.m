//
//  ViewController.m
//  Suion
//
//  Created by mjhd on 2014/08/04.
//  Copyright (c) 2014年 Yusuke Otsuka. All rights reserved.
//

#import "ViewController.h"
#import "ArcSlider.h"
#import "StartStopButton.h"
#import "SoundSelectorView.h"
#import "Sound.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet ArcSlider *VolumeSlider;
@property (weak, nonatomic) IBOutlet StartStopButton *StartStopButton;
@property (weak, nonatomic) IBOutlet UILabel *SoundLabel;
@property (weak, nonatomic) IBOutlet SoundSelectorView *SoundSelector;
@property (weak, nonatomic) IBOutlet UIImageView *BaseImage;
@property (weak, nonatomic) IBOutlet UIButton *AboutButton;

@end

@implementation ViewController
{
    NSMutableDictionary *_sounds;
    Sound *currentSound;
    NSUserDefaults *_defaults;
}


- (void)registerSounds {
    _sounds = [[NSMutableDictionary alloc] init];
    
    Sound *ameSound = [[Sound alloc] init];
    Sound *sunaSound = [[Sound alloc] init];
    Sound *gekiSound = [[Sound alloc] init];
    Sound *kyuuSound = [[Sound alloc] init];
    Sound *seseSound = [[Sound alloc] init];
    Sound *douSound = [[Sound alloc] init];
    
     ameSound.name = @"雨";
    sunaSound.name = @"砂浜";
    gekiSound.name = @"激流";
    kyuuSound.name = @"急流";
    seseSound.name = @"川瀬";
     douSound.name = @"洞窟";
    
     ameSound.shortName = @"雨";
    sunaSound.shortName = @"浜";
    gekiSound.shortName = @"激";
    kyuuSound.shortName = @"急";
    seseSound.shortName = @"川";
     douSound.shortName = @"洞";
    
    NSBundle *bundle = [NSBundle mainBundle];
    
     ameSound.soundFile = [bundle pathForResource:@"ame" ofType:@"caf"];
    sunaSound.soundFile = [bundle pathForResource:@"umi" ofType:@"caf"];
    gekiSound.soundFile = [bundle pathForResource:@"geki" ofType:@"caf"];
    kyuuSound.soundFile = [bundle pathForResource:@"kyuu" ofType:@"caf"];
    seseSound.soundFile = [bundle pathForResource:@"kawa" ofType:@"caf"];
     douSound.soundFile = [bundle pathForResource:@"dou" ofType:@"caf"];
    
    UIImage  *ameImage = [UIImage imageNamed:@"ameLarge.png"];
    UIImage *sunaImage = [UIImage imageNamed:@"umiLarge.png"];
    UIImage *gekiImage = [UIImage imageNamed:@"kawa4Large.png"];
    UIImage *kyuuImage = [UIImage imageNamed:@"kawa3Large.png"];
    UIImage *seseImage = [UIImage imageNamed:@"kawa2Large.png"];
    UIImage  *douImage = [UIImage imageNamed:@"douLarge.png"];
    
     ameSound.largeImage = ameImage;
    sunaSound.largeImage = sunaImage;
    gekiSound.largeImage = gekiImage;
    kyuuSound.largeImage = kyuuImage;
    seseSound.largeImage = seseImage;
     douSound.largeImage = douImage;
    
     ameSound.smallImage = NULL;
    sunaSound.smallImage = NULL;
    gekiSound.smallImage = NULL;
    kyuuSound.smallImage = NULL;
    seseSound.smallImage = NULL;
     douSound.smallImage = NULL;
    
     ameSound.baseColor = [UIColor colorWithRed:0.51764705882353f green:0.53725490196078f blue:0.5843137254902 alpha:1.0f];
    sunaSound.baseColor = [UIColor colorWithRed:0.47843137254902f green:0.66274509803922f blue:0.89019607843137 alpha:1.0f];
    gekiSound.baseColor = [UIColor colorWithRed:0.08627450980392f green:0.08627450980392f blue:0.08235294117647f alpha:1.0f];
    kyuuSound.baseColor = [UIColor colorWithRed:0.5921568627451f green:0.68627450980392f blue:0.53725490196078 alpha:1.0f];
    seseSound.baseColor = [UIColor colorWithRed:0.53333333333333f green:0.57647058823529f blue:0.25490196078431f alpha:1.0f];
    douSound.baseColor = [UIColor colorWithRed:0.64313725490196f green:0.59607843137255f blue:0.50588235294118f alpha:1.0f];
    
    [Sound prepare];
    [ ameSound prepare];
    [sunaSound prepare];
    [gekiSound prepare];
    [kyuuSound prepare];
    [seseSound prepare];
    [ douSound prepare];
    
    _sounds[ameSound.name] = ameSound;
    _sounds[sunaSound.name] = sunaSound;
    _sounds[gekiSound.name] = gekiSound;
    _sounds[kyuuSound.name] = kyuuSound;
    _sounds[seseSound.name] = seseSound;
    _sounds[douSound.name] = douSound;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

    
    _defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *def = @{
                           @"volume" : @0.5f,
                           @"sound": @3
                           };
    
    [_defaults registerDefaults:def];

    [self registerSounds];
    
    for (id key in [_sounds keyEnumerator]) {
        SoundSelectorCellAttribute *att = [[SoundSelectorCellAttribute alloc] init];
        Sound *sound = _sounds[key];
        
        att.text = sound.name;
        att.label = sound.shortName;
        if (sound.smallImage) {
            att.backgroundView = (UIView *)sound.smallImage;
        } else {
            UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
            colorView.backgroundColor = sound.baseColor;
            att.backgroundView = colorView;
        }

        [_SoundSelector appendCell:att];
    }
    
    _SoundSelector.selected = ^(NSIndexPath *indexPath, SoundSelectorCellAttribute *cell) {
        _SoundLabel.text = cell.text;
        
        if (_StartStopButton.selected) {
            [currentSound stop];
        }
        
        currentSound = (Sound *)_sounds[cell.text];
        
        if (_StartStopButton.selected) {
            [currentSound setVolume:_VolumeSlider.volume];
            [currentSound playLoop];
        }
        
        [_BaseImage setImage:currentSound.largeImage];
        
        UIColor *baseColor = ((Sound *)(_sounds[cell.text])).baseColor;
        CGFloat h, s, b, a;
        [baseColor getHue:&h saturation:&s brightness:&b alpha:&a];
        UIColor *volumeColor = [UIColor colorWithHue:h saturation:s+0.5 brightness:b+0.5 alpha:a];
        UIColor *ssNormalColor = [UIColor colorWithHue:h saturation:s+0.1 brightness:b+0.1 alpha:a];
        UIColor *ssPressedColor = [UIColor colorWithHue:h saturation:s+1.0 brightness:b+1.0 alpha:a];
        
        
        [_VolumeSlider setColor:volumeColor];
    
        [_StartStopButton setNormalColor:ssNormalColor];
        [_StartStopButton setPressedColor:ssPressedColor];
        
        [_defaults setInteger:indexPath.item forKey:@"sound"];
    };
    
    _VolumeSlider.changed = ^(float volume) {
        if (_StartStopButton.selected) {
            [currentSound setVolume:volume];
        }
        [_defaults setFloat:_VolumeSlider.volume forKey:@"volume"];
    };
    
    NSIndexPath *firstSelected = [NSIndexPath indexPathForItem:[_defaults integerForKey:@"sound"] inSection:0];
    [_SoundSelector selectCell:firstSelected];
    [_VolumeSlider setVolume:[_defaults floatForKey:@"volume"]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [Sound dealloc];
    [_defaults synchronize];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    [Sound dealloc];
    [_defaults synchronize];
}

- (IBAction)toggleSound:(id)sender {
    if (_StartStopButton.selected) {
        [currentSound stop];
    } else {
        [currentSound setVolume:_VolumeSlider.volume];
        [currentSound playLoop];
    }
}
@end
