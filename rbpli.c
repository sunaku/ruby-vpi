#include <stdio.h>
#include <stdlib.h>
#include <ruby.h>
#include <pthread.h>
#include <vpi_user.h>
#include <veriuser.h>

#define STARTUP_SCRIPT "pli_init.rb"

static pthread_t ruby_tid;
static pthread_mutex_t ruby_lock;
static pthread_mutex_t veri_lock;

static void
relay_init() {
  pthread_mutex_init(&ruby_lock, NULL);
  pthread_mutex_lock(&ruby_lock);
  pthread_mutex_init(&veri_lock, NULL);
  pthread_mutex_lock(&veri_lock);
}

static void relay_ruby(){
  pthread_mutex_unlock(&ruby_lock);
  pthread_mutex_lock(&veri_lock);
}
static void relay_veri(){
  pthread_mutex_unlock(&veri_lock);
  pthread_mutex_lock(&ruby_lock);
}
static VALUE
rb_relay_veri(VALUE self) {
  relay_veri();
  return Qnil;
}

static void *
ruby_run_handshake(void *dummy) {
  pthread_mutex_lock(&ruby_lock); /* block */
  ruby_run();
}

static s_cb_data cb_data;
int
rb_callback(char *data)
{
  puts("-> ruby");
  relay_ruby(); // wait for relay_veli();
  puts("-> verilog");
  return 0;
}

void
Init_vpi()
{
  VALUE mPLI = rb_define_module("PLI");
  rb_define_singleton_method(mPLI, "relay_verilog", rb_relay_veri, 0);
}

static int
rb_init(char *dummy)
{
  char *argv[] = {"ruby", STARTUP_SCRIPT};
  relay_init();
  ruby_init();
  ruby_options(sizeof(argv)/sizeof(char *), argv);
  Init_vpi();
  pthread_create(&ruby_tid, 0, ruby_run_handshake, 0);
}

static void setup_function(char *name, int (*func)(char*)) {
  s_vpi_systf_data tf;
  tf.type = vpiSysTask;
  tf.tfname = name;
  tf.calltf = func;
  tf.compiletf = 0;
  tf.sizetf = 0;
  tf.user_data = 0;
  vpi_register_systf(&tf);
}

static void startup() {
  setup_function("$ruby_init", rb_init);
  setup_function("$ruby_callback", rb_callback);
}

void (*vlog_startup_routines[])() = { startup, 0 };
