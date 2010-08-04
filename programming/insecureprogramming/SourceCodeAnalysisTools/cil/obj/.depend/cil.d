 $(OBJDIR)/cil.cmo:  $(OBJDIR)/util.cmi  $(OBJDIR)/trace.cmi  $(OBJDIR)/pretty.cmi \
      $(OBJDIR)/machdep.cmo  $(OBJDIR)/inthash.cmo  $(OBJDIR)/escape.cmi \
     $(OBJDIR)/errormsg.cmi  $(OBJDIR)/clist.cmi   $(OBJDIR)/cilversion.cmo \
     $(OBJDIR)/cil.cmi 
 $(OBJDIR)/cil.cmx:  $(OBJDIR)/util.cmx  $(OBJDIR)/trace.cmx  $(OBJDIR)/pretty.cmx \
      $(OBJDIR)/machdep.cmx  $(OBJDIR)/inthash.cmx  $(OBJDIR)/escape.cmx \
     $(OBJDIR)/errormsg.cmx  $(OBJDIR)/clist.cmx   $(OBJDIR)/cilversion.cmx \
     $(OBJDIR)/cil.cmi 
