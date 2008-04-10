/*
  Copyright 2008 Suraj N. Kurapati
  See the file named LICENSE for details.
*/

#include "thread.h"

void RubyVPI_thread_wait(pthread_mutex_t* lock, pthread_cond_t* cond, bool* state, bool value)
{
    pthread_mutex_lock(lock);
    {
        while (value != *state)
        {
            pthread_cond_wait(cond, lock);
        }
    }
    pthread_mutex_unlock(lock);
}

void RubyVPI_thread_flag(pthread_mutex_t* lock, pthread_cond_t* cond, bool* state, bool value)
{
    pthread_mutex_lock(lock);
    {
        *state = value;
        pthread_cond_signal(cond);
    }
    pthread_mutex_unlock(lock);
}
