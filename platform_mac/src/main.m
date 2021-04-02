#include <inttypes.h>
#include <stdio.h>
#import <AppKit/AppKit.h>

typedef int32_t s32;

static const s32 INITIAL_WINDOW_WIDTH = 1280;
static const s32 INITIAL_WINDOW_HEIGHT = 720;

@interface application_delegate : NSObject<NSApplicationDelegate, NSWindowDelegate>
@end

@implementation application_delegate
- (void)applicationDidFinishLaunching:(id)sender {
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification*)notification {
}

- (NSSize)windowWillResize:(NSWindow*)window toSize:(NSSize)frame_size {
    //frame_size.height = ((f32
    return frame_size;
}

- (void)windowWillClose:(id)sender {
}
@end

int main(void) {
    // NSApplication & Delegate creation.
    NSApplication *ns_app = [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    application_delegate *app_delegate = [[application_delegate alloc] init];
    [ns_app setDelegate:app_delegate];
    
    [NSApp finishLaunching];
    
    // Window creation.
    NSRect screen_rect = [[NSScreen mainScreen] frame];
    NSRect initial_content_rect = NSMakeRect(0.5f * (screen_rect.size.width - INITIAL_WINDOW_WIDTH), 0.5f * (screen_rect.size.height - INITIAL_WINDOW_HEIGHT), INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT);
    
    NSWindow *window = [[NSWindow alloc] initWithContentRect:initial_content_rect
                        styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable 
                        backing:NSBackingStoreBuffered
                        defer:NO];
    [window setBackgroundColor:NSColor.blackColor];
    [window setDelegate:app_delegate];
    [window setTitle:@"Axion"];
    [window makeKeyAndOrderFront:nil];
    
    for (;;) {
        // Update the window events.
        for (;;) {
            NSEvent *event = [NSApp nextEventMatchingMask:NSEventMaskAny
                              untilDate:nil
                              inMode:NSDefaultRunLoopMode
                              dequeue:YES];
            if (nil == event) {
                // No more events for us to process,
                // break.
                printf("No events!\n");
                break;
            }
            
            [NSApp sendEvent:event];
        }
    }
    
    return 0;
}
