interface OrchestratorInterface {
RequestResponse:
  println( string )( void ),
  subscribeSessionListener( string )( void ),
  enableTimestamp( bool )( void ),
  registerForInput( bool )( void ),
  print( string )( void),
  unsubscribeSessionListener( string )( void )
}
