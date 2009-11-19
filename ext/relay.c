//
// Copyright protects this work.
// See LICENSE file for details.
//

#ifdef HAVE_SYS_UCONTEXT_H
    #include <sys/ucontext.h>
#endif

#ifdef HAVE_UCONTEXT_H
    #include <ucontext.h>
#endif

#include "util.h"
#include "relay.h"
#include "binding.h"

static ucontext_t RubyVPI_relay_vlog_context;
static ucontext_t RubyVPI_relay_ruby_context;
static p_cb_data  RubyVPI_relay_ruby_reason;

void RubyVPI_relay_init_vlog_context()
{
    getcontext(&RubyVPI_relay_vlog_context);
}

PLI_INT32 RubyVPI_relay_from_vlog_to_ruby(p_cb_data callback)
{
    RubyVPI_relay_ruby_reason = callback;

    RubyVPI_util_debug("vlog to ruby begin");
    getcontext(&RubyVPI_relay_vlog_context);
    setcontext(&RubyVPI_relay_ruby_context);
    RubyVPI_util_debug("vlog to ruby end");

    return 0;
}

VALUE RubyVPI_relay_from_ruby_to_vlog(VALUE self)
{
    RubyVPI_util_debug("ruby to vlog begin");
    getcontext(&RubyVPI_relay_ruby_context);
    setcontext(&RubyVPI_relay_vlog_context);
    RubyVPI_util_debug("ruby to vlog end");

    RubyVPI_util_debug("callback = %p", RubyVPI_relay_ruby_reason);
    RubyVPI_util_debug("callback.user_data = %p", RubyVPI_relay_ruby_reason ? RubyVPI_relay_ruby_reason->user_data : 0);

    return RubyVPI_binding_rubify_callback(RubyVPI_relay_ruby_reason);
}
