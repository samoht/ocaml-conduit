open Async
open Async_ssl
open Conduit_async

type 'flow with_ssl = {
  connection : Ssl.Connection.t;
  reader : Reader.t;
  writer : Writer.t;
  underlying : 'flow;
}

type context = {
  version : Ssl.Version.t option;
  options : Ssl.Opt.t list option;
  name : string option;
  hostname : string option;
  allowed_ciphers :
    [ `Only of string list | `Openssl_default | `Secure ] option;
  ca_file : string option;
  ca_path : string option;
  crt_file : string option;
  key_file : string option;
  session : Ssl.Session.t option;
  verify_modes : Verify_mode.t list option;
  verify : (Ssl.Connection.t -> bool Async.Deferred.t) option;
}

val context :
  ?version:Ssl.Version.t ->
  ?options:Ssl.Opt.t list ->
  ?name:string ->
  ?hostname:string ->
  ?allowed_ciphers:[ `Only of string list | `Openssl_default | `Secure ] ->
  ?ca_file:string ->
  ?ca_path:string ->
  ?crt_file:string ->
  ?key_file:string ->
  ?session:Ssl.Session.t ->
  ?verify_modes:Verify_mode.t list ->
  ?verify:(Ssl.Connection.t -> bool Async.Deferred.t) ->
  unit ->
  context

val protocol_with_ssl :
  reader:('flow -> Reader.t) ->
  writer:('flow -> Writer.t) ->
  ('edn, 'flow) Client.protocol ->
  (context * 'edn, 'flow with_ssl) Client.protocol

val service_with_ssl :
  ('cfg, 't, 'flow) Service.service ->
  reader:('flow -> Reader.t) ->
  writer:('flow -> Writer.t) ->
  ('edn, 'flow with_ssl) Client.protocol ->
  (context * 'cfg, context * 't, 'flow with_ssl) Service.service

module TCP : sig
  open Conduit_async_tcp

  val protocol : (context * endpoint, Protocol.flow with_ssl) Client.protocol

  val service :
    ( context * Server.configuration,
      context * Server.t,
      Protocol.flow with_ssl )
    Service.service

  val resolv_conf :
    port:int -> context:context -> (context * endpoint) Client.resolver
end
