-module(elli_ssl_tests).
-include_lib("eunit/include/eunit.hrl").
-include("elli_test.hrl").

elli_ssl_test_() ->
    {setup,
     fun setup/0, fun teardown/1,
     [
      ?_test(hello_world())
     ]}.

%%% Tests

hello_world() ->
    {ok, Response} = httpc:request("https://localhost:3443/hello/world"),
    ?assertMatch(200, status(Response)).

%%% Internal helpers

setup() ->
    application:start(asn1),
    application:start(crypto),
    application:start(public_key),
    application:start(ssl),
    inets:start(),

    EbinDir  = filename:dirname(code:which(?MODULE)),
    CertDir  = filename:join([EbinDir, "..", "test"]),
    CertFile = filename:join(CertDir, "server_cert.pem"),
    KeyFile  = filename:join(CertDir, "server_key.pem"),

    {ok, P}  = elli:start_link([
                                {port, 3443},
                                ssl,
                                {keyfile, KeyFile},
                                {certfile, CertFile},
                                {callback, elli_example_callback}
                               ]),
    unlink(P),
    [P].

teardown(Pids) ->
    inets:stop(),
    application:stop(ssl),
    application:stop(public_key),
    application:stop(crypto),
    [elli:stop(P) || P <- Pids].
