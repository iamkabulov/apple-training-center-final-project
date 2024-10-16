import Foundation

let tokenString = "https://accounts.spotify.com/api/token"
let tokenURL = URL(string: tokenString)!
let accessTokenKey = "access-token-key"
let clientCredentialKey = "client-credentials"
let redirectUri = URL(string:"musicPlayerApp://")!
let spotifyClientId = "6c4cd976ad414790a825b0dc135137ad"
let spotifyClientSecretKey = "f25ee638c8e7431dbef93ee5cce0d991"

/*
Scopes let you specify exactly what types of data your application wants to
access, and the set of scopes you pass in your call determines what access
permissions the user is asked to grant.
For more information, see https://developer.spotify.com/web-api/using-scopes/.
*/
let scopes: SPTScope = [
							.userReadEmail, .userReadPrivate,
							.userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying,
							.streaming, .appRemoteControl,
							.playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate,
							.userLibraryModify, .userLibraryRead,
							.userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying,
							.userFollowRead, .userFollowModify,
						]
let stringScopes = [
						"user-read-email", "user-read-private",
						"user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
						"streaming", "app-remote-control",
						"playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
						"user-library-modify", "user-library-read",
						"user-top-read", "user-read-playback-position", "user-read-recently-played",
						"user-follow-read", "user-follow-modify",
					]
