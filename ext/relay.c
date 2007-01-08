/*
  Copyright 1999 Kazuhiro HIWADA
  Copyright 2006 Suraj N. Kurapati

  This file is part of Ruby-VPI.

  Ruby-VPI is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  Ruby-VPI is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Ruby-VPI; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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

    // XXX: freezee verilog because RubyVpi.init_bench will call relay_verilog (which assumes that verilog is frozen)
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
