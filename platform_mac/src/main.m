#import <AppKit/AppKit.h>
#include <dlfcn.h>
#include <inttypes.h>
#include <stdarg.h>
#include <stdio.h>
#include <sys/stat.h>

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

struct platform_app {
    void *library_handle;
    time_t library_last_write_time;
    app_functions funcs;
}

static void v_display_message_box(const char *title, const char *msg_format, va_list msg_args) {
    const size_t MAX_MSG_SIZE = 1024;
    
    // Format the message.
    // TODO: Replace this with a dynamically allocated buffer.
    char msg[MAX_MSG_SIZE + 1];
    
    // If the message is longer then the maximum message size, then there's
    // nothing for us to do here. It's better to display a shortened message,
    // then to display nothing at all...
    vsnprintf(buf, sizeof(buf), msg_format, msg_args);
    
    // Display the message box.
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    
    NSString *title_string = [NSString stringWithUTF8String:title];
    NSString *msg_string = [NSString stringWithUTF8String:msg];
    [alert setMessageText:title_string];
    [alert setInformationText:msg_string];
    
    [alert runModal];
}

static void display_message_box(const char *title, const char *msg_format, ...) {
    va_list msg_args;
    va_start(msg_args, msg_format);
    v_display_message_box(title, msg_format, args);
    va_end(msg_args);
}

static void display_error_box(const char *msg_format, ...) {
    va_list msg_args;
    va_start(msg_args, msg_format);
    v_display_message_box("Error", msg_format, args);
    va_end(msg_args);
}

static time_t get_file_modification_time(const char *path) {
    struct stat file_stat;
    if (0 != stat(path, &file_stat)) {
        return 0;
    }
    
    return file_stat.st_mtimespec.tv_sec;
}

static int load_app(struct platform_app *out_app, const char *app_library_path) {
    int res = 1;
    
    struct platform_app app;
    app.library_last_write_time = get_file_modification_time(app_library_path);
    
    app.library_handle = dlopen(app_library_path, RTLD_LAZY | RTLD_GLOBAL);
    if (app.library_handle) {
        display_error_box("Failed to open the app library, error: [%s]\n", dlerror());
        goto out;
    }
    
    *out_app = app;
    res = 0;
    
    out:
    return res;
}

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
    
    // Load the app shared library.
    if (0 != load_app()) {
        return 1;
    }
    
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
                break;
            }
            
            [NSApp sendEvent:event];
        }
        
        app_step(
    }
    
    return 0;
}
