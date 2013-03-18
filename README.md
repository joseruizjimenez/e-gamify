## About this project
E-gamify is gamification plataform for e-commerces, allowing an easy integration through javascript widgets

We want:
  - An easy integration with existing online shops (specially for those made through services like shopify.com or 1and1.com)
  - Non programmers can use the service just placing HTML tags on the right web pages templates (all services mentioned above let you do that)
  - It should raise customer's actions and build a community around the shop with the final goal of increasing the salles

To do:
  - Add quest/goals graph: editor for admins and badges system for customers.
  - Add a widgets catalog with docs, plus a few more widgets.
  - Rewards and coupons redeem plataform and admin's equivalent
  - Analitics dashboard

Note: Main module and public API are still under develpment.

Have fun :)

## Contributing
Feel free to send pull requests via GitHub, also you can contact me at joseruizjimenez@gmail.com

For any new features, bugfix or security warning, please do:
  1. Follow the style of the existing code.
  2. One commit should do just one thing
  3. Commit messages are key on the pull request, please use them properly

Any help is welcomed :)

## Production configuration
If you want to deploy it under a production environment, you need to set the following ENV variables:
  - GMAIL_USERNAME (with a gmail account for the app to use)
  - GMAIL_PASSWORD (the gmail password)
  - SECRET_TOKEN (with the app secret token, generate one with 'rake secret')
  - MONGODB_URI (database should should be named 'e_gamify')
  - MONGO_USERNAME (mongodb username)
  - MONGO_PASSWORD (mongodb pass)

## Copyright and license
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
