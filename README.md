# ProjectNexus

ProjectNexus is a Flutter prototype for student project team formation and teacher-guided project review.

## Run locally

From the project directory:

```powershell
flutter pub get
flutter run -d chrome
```

## Project and team workflow

1. A student submits a project with a description, required skills, and a selected teacher.
2. Only that teacher can approve or reject the submission. Approved projects with open recruitment appear in the project feed.
3. Students can apply once per project. Each application snapshots the student's profile skills and portfolio so project leaders can compare them with the requested skills and review them after switching accounts.
4. Team size is not capped by the app. The project leader closes or reopens recruitment when appropriate.
5. Only the project leader, accepted team members, and assigned teacher can access an approved project's workspace.

## Prototype limitations

Accounts and workflow data currently live in application memory and reset when the app restarts. Authentication is simulated, and there is no Firebase or file upload integration yet; this prototype must not be treated as a production system for sensitive student data.
