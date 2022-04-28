class Urls {
  static const HOST = "https://chaleeetask.com";
// static const HOST = "http://10.0.2.2:8000";
  static const SIGN_UP = HOST + "/api/auth/register/";
  static const LOGIN = HOST + "/api/auth/login/";
  static const FORGET_PASSWORD = HOST + "/api/auth/forget-password/";
  static const LOGIN_GOOGLE = HOST + "/api/auth/google-login/";
  static const LOG_OUT = HOST + "/api/auth/logout/";
  static const PROFILE = HOST + "/api/auth/profile-data/get/";
  static const SET_PROFILE = HOST + "/api/auth/profile-data/update/";
  static const SET_PROFILE_IMAGE = HOST + "/api/auth/profile-image/set/";
  static const SEARCH_USERS = HOST + "/api/auth/search/users/";
  static const ADD_USER = HOST + "/api/auth/contacts/add/";
  static const USERS = HOST + "/api/auth/contacts/get/";
  static const PROJECTS = HOST + "/api/project/list/";
  static const MY_PROJECTS = HOST + "/api/project/list/admin/";
  static const ADD_PROJECT = HOST + "/api/project/add/";
  static const DELETE_PROJECT = HOST + "/api/project/delete/";
  static const PROJECT_COMMENTS = HOST + "/api/project/list/comment/";
  static const NEW_COMMENT = HOST + "/api/project/comment/post/";
  static const PROJECT_TASKS = HOST + "/api/project/list/task/";
  //todo update
  //static const PROJECT_TASKS_ACCEPTED = HOST + "/api/task/messages/accepted/user/";
  static const PROJECT_TASKS_ACCEPTED = HOST + "/api/project/list/task/user/";
  static const ADD_TASK = HOST + "/api/task/add/";
  static const DELETE_TASK = HOST + "/api/task/remove/";
  static const ADD_GOAL = HOST + "/api/goal/add/";
  static const DELETE_GOAL = HOST + "/api/goal/remove/";
  static const UPDATE_GOAL = HOST + "/api/goal/update/";
  static const ADD_FILE_GOAL = HOST + "/api/goal/comment/post/";
  static const COMMENT_GOAL = HOST + "/api/goal/list/comments/";
  static const ADD_COMMENT_GOAL = HOST + "/api/goal/comment/post/";
  static const LIKE_COMMENT_GOAL = HOST + "/api/goal/comment/like/";
  static const UNLIKE_COMMENT_GOAL = HOST + "/api/goal/comment/unlike/";
  static const GOALS = HOST + "/api/goal/list/";

  static const CHATS = HOST + "/api/chat/list/";
  static const PRIVATE_CHAT = HOST + "/api/chat/private-chat/show/";
  static const SEND_PRIVATE_CHAT = HOST + "/api/chat/private-chat/post/";

  static const CREATE_GROUP_CHAT = HOST + "/api/chat/group/create/";
  static const GROUP_CHATS = HOST + "/api/chat/group-chat/show/";
  static const SEND_GROUP_CHAT = HOST + "/api/chat/group-chat/post/";

  static const PENDING_TASK =HOST + "/api/task/messages/requests/user/";
  static const PENDING_TASK_ADMIN =HOST + "/api/project/list/task/admin/";
  static const PENDING_TASK_ADMIN_SEEN =HOST + "/api/task/seen/";

  static const FIREBASE_UPDATE = HOST + "/api/auth/firebase-token/";

  static const ACCEPT_TASK = HOST + "/api/task/messages/requests/answer/";

  static const VIEW_SOCCER_PROFILE = HOST + '/api/task/poll/projects/';
  static const VIEW_SOCCER_PROFILE_DATA = HOST + '/api/task/poll/tasks/';
  static const SET_SOCCER = HOST + '/api/task/poll/post/';
  static const GET_USER_POLL = HOST + '/api/task/poll/list/users/';
  static const GET_USER_LIST = HOST + '/api/task/poll/users/';
  static const END_GOAL = HOST + '/api/goal/end/';

  static const ARCHIVE_PROJECT = HOST + '/api/project/list/archive/';
  static const ARCHIVE_PROJECT_TASK = HOST + '/api/project/list/archive/tasks/';

  static const PAYMENT = HOST + '/api/payment/start';
}
