# Hláškomat
aka. *TheQuote Frontend*

A frontend app for [TheQuoter backend](https://github.com/MaximMaximS/TheQuoter) written in Flutter.

Implements a RESTful API to communicate with the backend. **Login handling is yet to be *dealt with***

## Implemented Features
### Catalog
The current version of the app allows for a user to display a quote from the database at random or browse the catalog.

The catlog has a **filter and sort** functionality based on quote properties and their originators. Users can **search** for a quote or any of its properties in full text. Quote IDs can be searched for as well, aldough not visible to the user.

Users can create new quotes and submit them for review by admins.

Administrators can **Approve** or **Delete** quotes submited by users or create their own. Existing quotes can also be **Edited** complete with their contexts and notes; or assigned to a class of users. Every quote has its originator assignable from the app.

## Features planned
- [x] Quote catalog
- [x] Random quote display
- [x] Catalog filtering and searching
- [x] Slidable actions on quote cards
- [x] Quote creation and editing
- [ ] Quote sharing functionality
- [ ] Leagues
- [ ] Quote rating (up/down voting)
- [ ] Quote of the day functionality
- [ ] User data editing
- [ ] Moderator user type
- [ ] Personalization

## License

**Note:**
*This software can be used according to the MIT license, but we, the developers, would like you to deal with any of it in good faith and good intention. It only serves its purpose when it brings joy to the users and developers. This project is open to anyone who wants to participate and or deploy it.*

Published under **MIT License** as written in full [here](./LICENSE)
(C)2022 Matyáš Levíček - with passion for learing from Beroun, Czech Republic