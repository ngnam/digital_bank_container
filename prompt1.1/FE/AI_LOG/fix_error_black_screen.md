Done — route and DI updated

What I changed

Added an optional helper in di.dart:
registerDashboardCubitSingleton() — call this from main() if you want a single, app-scoped DashboardCubit registered in DI. It safely skips registration if a singleton already exists.
Updated main.dart:
The /dashboard route now returns a provider-wrapped DashboardPage.
Behavior:
If DashboardCubit is registered in DI, the route uses BlocProvider.value with the singleton so the same cubit instance is reused.
If not registered, the route creates a new DashboardCubit (via DashboardCubit(di.sl())) and calls ..loadAccounts() so the page works standalone.
Why this helps

Direct navigation to /dashboard now works whether you prefer:
an app-wide singleton cubit (registered in DI), or
a route-local cubit instance.
This keeps behavior flexible and avoids duplicate-provider errors or "Provider not found" issues.
Next steps and how to use

To use an app-scoped DashboardCubit (singleton), call the helper in main() after await di.init();:

Then navigation to /dashboard will reuse that singleton.

If you prefer per-page cubits, do nothing — the route will create a cubit instance on-the-fly.

Verification

I ran flutter analyze — no issues found.
If you'd like I can:

Register the dashboard singleton by default in di.init() for dev flavor only (useful for testing), or
Move all cubit registrations into DI and use DI everywhere for consistency.
Which approach would you prefer?