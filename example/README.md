# CDX Chat Example

This is an example application demonstrating how to use the `cdx_chat` package.

## Features Demonstrated

- ✅ Setting up localization with `CdxChatLocalizations`
- ✅ Implementing `ChatService` (in-memory example)
- ✅ Using `ChatProvider` for state management
- ✅ Displaying messages with default widgets
- ✅ Sending messages and replies
- ✅ Deleting messages
- ✅ Blocking/unblocking users
- ✅ Message validation
- ✅ Error handling

## Note

This example uses an in-memory implementation of `ChatService` that demonstrates:
- Fetching messages via streams
- Sending messages and replies
- Deleting messages
- Marking messages as read
- Blocking/unblocking users

For a complete example using a real backend, implement `ChatService` to call your API.

## Running the Example

1. Make sure you have Flutter installed
2. Navigate to this directory:
   ```bash
   cd example
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Implementation Details

### ExampleChatService

This is a simple in-memory implementation of `ChatService` that demonstrates:
- Streaming messages
- Sending messages and replies
- Deleting messages
- Marking messages as read
- Blocking/unblocking users

In a real application, you would replace this with an implementation that calls your backend API.

## Customization

You can customize the example by:
- Modifying the `ChatConfig` to change message length limits
- Changing the `UserInfo` to use different user data
- Implementing a real `ChatService` that calls your API
- Customizing the theme, text styles, and app actions

