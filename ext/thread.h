/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#ifndef THREAD_H
#define THREAD_H

    #include <pthread.h>
    #include <stdbool.h>

    ///
    /// Makes the caller wait *until* the given state has the given value.
    ///
    void RubyVPI_thread_wait(pthread_mutex_t* lock, pthread_cond_t* cond, bool* state, bool value);

    ///
    /// Applies the given value to the given state
    /// and notifies all observers of the change.
    ///
    void RubyVPI_thread_flag(pthread_mutex_t* lock, pthread_cond_t* cond, bool* state, bool value);

#endif
