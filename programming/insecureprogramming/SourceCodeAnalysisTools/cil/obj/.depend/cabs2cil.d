  $(OBJDIR)/cabs2cil.cmo:  $(OBJDIR)/util.cmi  $(OBJDIR)/trace.cmi \
     $(OBJDIR)/pretty.cmi   $(OBJDIR)/machdep.cmo  $(OBJDIR)/errormsg.cmi \
      $(OBJDIR)/cprint.cmo  $(OBJDIR)/cilutil.cmo  $(OBJDIR)/cil.cmi   $(OBJDIR)/cabs.cmo \
      $(OBJDIR)/cabs2cil.cmi 
  $(OBJDIR)/cabs2cil.cmx:  $(OBJDIR)/util.cmx  $(OBJDIR)/trace.cmx \
     $(OBJDIR)/pretty.cmx   $(OBJDIR)/machdep.cmx  $(OBJDIR)/errormsg.cmx \
      $(OBJDIR)/cprint.cmx  $(OBJDIR)/cilutil.cmx  $(OBJDIR)/cil.cmx   $(OBJDIR)/cabs.cmx \
      $(OBJDIR)/cabs2cil.cmi 
