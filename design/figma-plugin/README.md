# Code Wise Academy: Figma wireframe builder

This small Figma plugin builds the 9 Code Wise Academy wireframe screens as real, editable Figma frames in your own file. It uses the same colours and text as the Flutter app (`lib/theme/app_theme.dart`).

What it creates, on a new page called **Code Wise Academy Wireframes**:

- 9 frames (360 x 800): 01 Splash, 02 Sign Up, 03 Login, 04 Course Catalog, 05 Course Details, 06 Lesson Player, 07 Coding Exercise, 08 Progress Dashboard, 09 Profile
- Colour styles under **Code Wise/** (Black #111111, Yellow #F5C518, Card, Border, Grey text, Green, Red and more)
- A **Components** board with Yellow button, Outline button, Text field, Course card and Bottom nav. The screens use instances of these.
- Prototype links, with a flow called **Code Wise demo** that starts on Splash

## Run it (about 5 minutes)

Plugins you load from your own computer only run in the **Figma desktop app**, not in the browser.

1. Install the Figma desktop app from https://www.figma.com/downloads/ and sign in with your Figma account.
2. Create a new **Design file** and name it **Code Wise Academy Wireframes**.
3. In the top menu, go to **Plugins > Development > Import plugin from manifest...**, then pick `C:\codewise\design\figma-plugin\manifest.json`.
4. Run it from **Plugins > Development > Code Wise Academy Wireframes**. The screens appear after a few seconds.
5. Press **Play** (top right, or Shift + Space) to try the prototype.

You only import the plugin once. If you run it again, it adds a fresh page, so delete the old page first if you want only one copy.

## Prototype links

| From | Tap | Goes to |
| --- | --- | --- |
| Splash | after 2 seconds | Login |
| Login | LOG IN, Continue with Google | Course Catalog |
| Login | New here? Create account | Sign Up |
| Sign Up | SIGN UP | Course Catalog |
| Sign Up | Already have an account? Log in | Login |
| Course Catalog | Python for Beginners card | Course Details |
| Course Details | ENROL NOW / back arrow | Lesson Player / Catalog |
| Lesson Player | START EXERCISE / back arrow | Coding Exercise / Course Details |
| Coding Exercise | CONTINUE / X | Progress Dashboard / Lesson Player |
| Progress Dashboard | Resume | Lesson Player |
| Profile | Log out | Login |
| Bottom nav (every screen) | Home, My Learning, Profile | Catalog, Progress Dashboard, Profile |

## Exporting for the coursework

Select all 9 frames, go to **Export** in the right panel, choose **PNG** at **2x**, and click Export. You can also share the file link with view access (Share > Anyone with the link > can view).
