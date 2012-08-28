#import "cocos2d.h"
#import "Main.h"

@interface Highscores : Main <UITextFieldDelegate>
{
	NSString *currentPlayer;
	int currentScore;
	int currentScorePosition;
	NSMutableArray *highscores;
	UIAlertView *changePlayerAlert;
	UITextField *changePlayerTextField;
  UIViewController *vc;

}
@property(nonatomic, assign) UIViewController *vc;

- (id)initWithScore:(int)lastScore;
@end
