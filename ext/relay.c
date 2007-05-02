/*
  Copyright 1999 Kazuhiro HIWADA
  Copyright 2006 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include "relay.h"
#include "main.h"
#include <pthread.h>


pthread_t relay__rubyThread;
pthread_mutex_t relay__rubyLock;
pthread_mutex_t relay__verilogLock;

// Body of the ruby thread.
void* relay_ruby_thread(void* dummy) {
  main_init();
  return NULL;
}

void relay_init() {
  pthread_mutex_init(&relay__rubyLock, NULL);
  pthread_mutex_lock(&relay__rubyLock);
  pthread_mutex_init(&relay__verilogLock, NULL);
  pthread_mutex_lock(&relay__verilogLock);

  // start the ruby thread
    pthread_create(&relay__rubyThread, NULL, relay_ruby_thread, NULL);

    // XXX: freezee verilog because RubyVpi.init_bench will call relay_verilog
    // (which assumes that verilog is frozen)
    pthread_mutex_lock(&relay__verilogLock);
}

void relay_ruby() {
  pthread_mutex_unlock(&relay__rubyLock);
  pthread_mutex_lock(&relay__verilogLock);
}

void relay_verilog() {
  pthread_mutex_unlock(&relay__verilogLock);
  pthread_mutex_lock(&relay__rubyLock);
}
