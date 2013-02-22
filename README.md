## About this project
Anotar is a taking note Ruby on Rails web app

We want:
  - A fast web app
  - Liquid templates to show a simple and beautiful interface on any device (Bootstrap)
  - Zero learning curve

To do:
  - Add AJAX index showing new notes
  - Finish all the features and specs tests
  - Add complex search logic
  - Add Javascript note's text styling in client, not in server

Note: Admins console at /admins/console (Must be logged as an admin = true User)

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

## Copyright and license
Copyright 2012 Anotar.me

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
