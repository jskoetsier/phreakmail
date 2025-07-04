# Contribution Guidelines
**_Last modified on 15th August 2024_**

First of all, thank you for wanting to provide a bugfix or a new feature for the phreakmail community, it's because of your help that the project can continue to grow!

As we want to keep phreakmail's development structured we setup these Guidelines which helps you to create your issue/pull request accordingly.

**PLEASE NOTE, THAT WE MIGHT CLOSE ISSUES/PULL REQUESTS IF THEY DON'T FULLFIL OUR WRITTEN GUIDELINES WRITTEN INSIDE THIS DOCUMENT**. So please check this guidelines before you propose a Issue/Pull Request.

## Topics

- [Pull Requests](#pull-requests)
- [Issue Reporting](#issue-reporting)
    - [Guidelines](#issue-reporting-guidelines)
    - [Issue Report Guide](#issue-report-guide)

## Pull Requests
**_Last modified on 15th August 2024_**

However, please note the following regarding pull requests:

1. **ALWAYS** create your PR using the staging branch of your locally cloned phreakmail instance, as the pull request will end up in said staging branch of phreakmail once approved. Ideally, you should simply create a new branch for your pull request that is named after the type of your PR (e.g. `feat/` for function updates or `fix/` for bug fixes) and the actual content (e.g. `sogo-6.0.0` for an update from SOGo to version 6 or `html-escape` for a fix that includes escaping HTML in phreakmail).
2. **ALWAYS** report/request issues/features in the english language. This is done to allow other GitHub users to reply to your issues/requests too which did not speak other languages besides english.
3. Please **keep** this pull request branch **clean** and free of commits that have nothing to do with the changes you have made (e.g. commits from other users from other branches). *If you make changes to the `update.sh` script or other scripts that trigger a commit, there is usually a developer mode for clean working in this case.*
4. **Test your changes before you commit them as a pull request.** <ins>If possible</ins>, write a small **test log** or demonstrate the functionality with a **screenshot or GIF**. *We will of course also test your pull request ourselves, but proof from you will save us the question of whether you have tested your own changes yourself.*
5. **Please use** the pull request template we provide once creating a pull request. *HINT: During editing you encounter comments which looks like: `<!-- CONTENT -->`. These can be removed or kept, as they will not rendered later on GitHub! Please only create actual content without the said comments.*
6. Please **ALWAYS** create the actual pull request against the staging branch and **NEVER** directly against the master branch. *If you forget to do this, our moobot will remind you to switch the branch to staging.*
7. Wait for a merge commit: It may happen that we do not accept your pull request immediately or sometimes not at all for various reasons. Please do not be disappointed if this is the case. We always endeavor to incorporate any meaningful changes from the community into the phreakmail project.
8. If you are planning larger and therefore more complex pull requests, it would be advisable to first announce this in a separate issue and then start implementing it after the idea has been accepted in order to avoid unnecessary frustration and effort!

---

## Issue Reporting
**_Last modified on 15th August 2024_**

If you plan to report a issue within phreakmail please read and understand the following rules:

### Issue Reporting Guidelines

1. **ONLY** use the issue tracker for bug reports or improvement requests and NOT for support questions. For support questions you can either contact the [phreakmail community on Telegram](https://docs.phreakmail.com/#community-support-and-chat) or the phreakmail team directly in exchange for a [support fee](https://docs.phreakmail.com/#commercial-support).
2. **ONLY** report an error if you have the **necessary know-how (at least the basics)** for the administration of an e-mail server and the usage of Docker. phreakmail is a complex and fully-fledged e-mail server including groupware components on a Docker basement and it requires a bit of technical know-how for debugging and operating.
3. **ALWAYS** report/request issues/features in the english language. This is done to allow other GitHub users to reply to your issues/requests too which did not speak other languages besides english.
4. **ONLY** report bugs that are contained in the latest phreakmail release series. *The definition of the latest release series includes the last major patch (e.g. 1.0.0) and all minor patches (revisions) below it (e.g. 1.0.1, 1.0.2, etc.).* New issue reports must meet this criterion, as versions below the latest releases are no longer supported by us.
5. When reporting a problem, please be as detailed as possible and include even the smallest changes to your mailcow installation. Simply fill out the corresponding bug report form in detail and accurately to minimize possible questions.
6. **Before you open an issue/feature request**, please first check whether a similar request already exists in the mailcow tracker on GitHub. If so, please include yourself in this request.
7. When you create a issue/feature request: Please note that the creation does <ins>**not guarantee an instant implementation or fix by the phreakmail team or the community**</ins>.
8. Please **ALWAYS** anonymize any sensitive information in your bug report or feature request before submitting it.

### Issue Report Guide
1. Read your logs; follow them to see what the reason for your problem is.
2. Follow the leads given to you in your logfiles and start investigating.
3. Restarting the troubled service or the whole stack to see if the problem persists.
4. Read the [documentation](https://docs.phreakmail.com/) of the troubled service and search its bugtracker for your problem.
5. Search our [issues](https://github.com/phreak/phreakmail/issues) for your problem.
6. [Create an issue](https://github.com/phreak/phreakmail/issues/new/choose) over at our GitHub repository if you think your problem might be a bug or a missing feature you badly need. But please make sure, that you include **all the logs** and a full description to your problem.
7. Ask your questions in our community-driven [support channels](https://docs.phreakmail.com/#community-support-and-chat).

## When creating an issue/feature request or a pull request, you will be asked to confirm these guidelines.
