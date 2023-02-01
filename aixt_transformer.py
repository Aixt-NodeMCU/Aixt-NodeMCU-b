# This file is part of the Aixt project, https://gitlab.com/fermarsan/aixt-project.git
#
# The MIT License (MIT)
# 
# Copyright (c) 2023 Fernando Martínez Santa

from lark import Transformer, v_args
import yaml

@v_args(inline=True)
class aixt_transformer(Transformer):
    def __init__(self):
        self.symbols = {}
        self.error_s = ''       #error stream
        self.output_s = ''      #output stream
        self.exType = ''
        self.lineno = 1
        self.identifiers = []   #stacks

        self.typeStack = []     #[type, value]
        
        self.main = False
        self.includes = ''
        self.module_def = ''
        self.preprocessor = ''
        self.top_level = ''
        
        with open(r'./setup.yaml','r') as setup_file:
            self.setup = yaml.load(setup_file, Loader=yaml.FullLoader)
            # for s in self.setup:
            #     print(s)

    @v_args(inline=False)
    def source_file(self, sf):
        output = ''
        for line in sf:
            output += line
        return output

    def stmt(self, st):
        return '{};'.format(st)
    
    def assign_stmt(self, ex1,op,ex2):
        return '{} {} {}'.format(ex1,op,ex2)

    @v_args(inline=False)
    def assign_op(self, op):
        if len(op) == 1:
            return '{}'.format(*op)     # "="
        elif len(op) == 2:
            return '{}{}'.format(*op)   # "+=", "<<=", etc.

    def expr(self, ex):
        return '{}'.format(ex)

    def conversion(self, tn,lp,ex,rp):
        self.typeStack[-1][0] = tn      #changes the default type 
        return '{}({})'.format(tn,ex)

    def type_name(self, tn):
        return '{}'.format(tn)

    def numeric_type(self, nt):
        return '{}'.format(nt)

    def literal(self, n):
        return '{}'.format(n)

    def string_literal(self, sl):
        s = sl.replace("'",'"')
        self.typeStack.append(['char []', s])
        return s

    def char_literal(self, cl):
        s = cl.replace('`',"'")
        self.typeStack.append(['char', s])
        return s

    def bool_literal(self, bl):
        return '{}'.format(bl)

    def float_literal(self, fl):
        s = fl.replace('_', '') # remove "_"
        self.typeStack.append([self.setup['default_float'], s])
        return '{}'.format(eval(s))     # eval adds missing zeros at both sides of "."
        
    def integer_literal(self, il):
        s = il.replace('_', '') # remove "_"
        self.typeStack.append([self.setup['default_int'], s])
        return '{}'.format(s)

    @v_args(inline=False)
    def eos(self, eo):
        return '\n'   

