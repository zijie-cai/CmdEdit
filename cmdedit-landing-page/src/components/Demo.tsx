import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Terminal, Command, Search, ChevronLeft, Star, Code, CornerDownLeft } from 'lucide-react';

const FLOW = [
  { step: 'terminal-startup', duration: 600 },
  { step: 'terminal-login', duration: 800 },
  { step: 'terminal-idle', duration: 1200 },
  { step: 'terminal-typing', duration: 1800 },
  { step: 'terminal-tooltip', duration: 0 },
  { step: 'editor-open', duration: 1500 },
  { step: 'editor-history-press', duration: 800 },
  { step: 'history-open', duration: 1200 },
  { step: 'history-hover', duration: 1800 },
  { step: 'editor-history-selected', duration: 1800 },
  { step: 'editor-select-word', duration: 1200 },
  { step: 'editor-delete-word', duration: 600 },
  { step: 'editor-type-word', duration: 2000 },
  { step: 'editor-save', duration: 1200 },
  { step: 'terminal-final', duration: 1200 },
  { step: 'terminal-execute', duration: 1000 },
  { step: 'terminal-replay', duration: 0 },
];

export function Demo() {
  const [currentStepIndex, setCurrentStepIndex] = useState(0);
  const currentStepRef = React.useRef(0);

  useEffect(() => {
    let isMounted = true;
    let resolveWait: (() => void) | null = null;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (!resolveWait) return;
      
      const step = FLOW[currentStepRef.current].step;
      
      if (step === 'terminal-replay' && e.key === 'Enter') {
        e.preventDefault();
        resolveWait();
        resolveWait = null;
      } else if (step === 'terminal-tooltip' && e.key.toLowerCase() === 'e' && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        resolveWait();
        resolveWait = null;
      }
    };
    window.addEventListener('keydown', handleKeyDown);

    const runFlow = async () => {
      while (isMounted) {
        for (let i = 0; i < FLOW.length; i++) {
          if (!isMounted) break;
          setCurrentStepIndex(i);
          currentStepRef.current = i;
          
          if (FLOW[i].step === 'terminal-replay' || FLOW[i].step === 'terminal-tooltip') {
            await new Promise<void>(resolve => { resolveWait = resolve; });
          } else {
            await new Promise(r => setTimeout(r, FLOW[i].duration));
          }
        }
      }
    };
    runFlow();
    return () => { 
      isMounted = false; 
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, []);

  const step = FLOW[currentStepIndex].step;
  const isCmdEditOpen = step.startsWith('editor') || step.startsWith('history');
  const isTerminalFinal = step === 'terminal-final' || step === 'terminal-execute' || step === 'terminal-replay';

  return (
    <div className="relative w-full h-full flex items-center justify-center overflow-hidden">
      {/* Background Terminal (macOS Theme) */}
      <motion.div 
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ type: "spring", stiffness: 300, damping: 25 }}
        className="absolute inset-0 m-12 bg-[#1C1C1E] rounded-xl border border-white/10 shadow-2xl flex flex-col overflow-hidden pointer-events-none select-none z-10"
      >
            {/* macOS Title Bar */}
          <div className="h-12 bg-[#2D2D2D] flex items-center px-4 relative border-b border-black/40">
            <div className="flex gap-2 absolute left-4">
              <div className="w-3 h-3 rounded-full bg-[#FF5F56] border border-black/20" />
              <div className="w-3 h-3 rounded-full bg-[#FFBD2E] border border-black/20" />
              <div className="w-3 h-3 rounded-full bg-[#27C93F] border border-black/20" />
            </div>
            <div className="flex-1 text-center text-white/50 text-xs font-sans font-medium">
              user — -zsh — 80x24
            </div>
            <div className="absolute right-4 text-white/30 text-[10px] font-sans font-bold uppercase tracking-widest px-2 py-1 rounded-md border border-white/10 bg-white/5">
              Demo
            </div>
          </div>
          
          <div className="p-4 flex flex-col gap-2 font-mono text-[13px] text-white/90">
            {/* Last login text */}
            {step !== 'terminal-startup' && (
              <div className="text-white/60 mb-2">
                Last login: Mon Mar 23 09:45:12 on ttys001
              </div>
            )}
            
            {/* Current command line */}
            {step !== 'terminal-startup' && step !== 'terminal-login' && (
              <div className="flex items-start gap-2">
                <span className="text-white font-bold">~/project %</span>
                <div className="relative flex-1">
                  {step === 'terminal-idle' && (
                    <Cursor />
                  )}
                  
                  {(!isTerminalFinal && step !== 'terminal-startup' && step !== 'terminal-login' && step !== 'terminal-idle') && (
                    <span className="text-white/90 relative inline-block whitespace-pre-wrap">
                      <Typewriter text='curl -X POST \' step={step} trigger="terminal-typing" />
                      {!isCmdEditOpen && (
                        <Cursor />
                      )}
                      
                      {step === 'terminal-tooltip' && (
                        <motion.div
                          initial={{ opacity: 0, y: 10 }}
                          animate={{ opacity: 1, y: 0 }}
                          className="absolute left-0 top-8 bg-[#2D2D2D] border border-white/10 px-3 py-2 rounded-md text-xs font-sans flex items-center gap-3 shadow-xl z-10 whitespace-nowrap"
                        >
                          <kbd className="font-mono bg-[#111] text-white px-2 py-1 rounded-sm text-[11px] font-bold tracking-wider">⌃E</kbd>
                          <span className="text-white font-medium tracking-wide">to edit</span>
                        </motion.div>
                      )}
                    </span>
                  )}
                  
                  {isTerminalFinal && (
                    <motion.div
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      className="text-white/90 font-mono whitespace-pre-wrap"
                    >
                      <span>{`curl -X POST \\\n  https://api.example.com/v1/data \\\n  -H "Authorization: Bearer new_token" \\\n  -d '{"status": "active"}'`}</span>
                      {step === 'terminal-final' && (
                        <Cursor />
                      )}
                    </motion.div>
                  )}
                </div>
              </div>
            )}
            
            {/* Executed output */}
            {(step === 'terminal-execute' || step === 'terminal-replay') && (
              <motion.div
                initial={{ opacity: 0, y: 5 }}
                animate={{ opacity: 1, y: 0 }}
                className="mt-2 text-white/70 font-mono text-[13px]"
              >
                {`{"success": true, "message": "Data updated"}`}<br/>
              </motion.div>
            )}
            {(step === 'terminal-execute' || step === 'terminal-replay') && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.5 }}
                className="flex items-start gap-2 mt-2"
              >
                <span className="text-white font-bold">~/project %</span>
                <div className="relative flex-1">
                  <Cursor />
                  {step === 'terminal-replay' && (
                    <motion.div
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="absolute left-0 top-8 bg-[#2D2D2D] border border-white/10 px-3 py-2 rounded-md text-xs font-sans flex items-center gap-3 shadow-xl z-10 whitespace-nowrap"
                    >
                      <kbd className="font-mono bg-[#111] text-white px-2 py-1 rounded-sm text-[11px] font-bold tracking-wider">↵</kbd>
                      <span className="text-white font-medium tracking-wide">to replay</span>
                    </motion.div>
                  )}
                </div>
              </motion.div>
            )}
          </div>
        </motion.div>

      {/* Overlay Blur */}
      <AnimatePresence>
        {isCmdEditOpen && (
          <motion.div
            initial={{ opacity: 0, backdropFilter: 'blur(0px)' }}
            animate={{ opacity: 1, backdropFilter: 'blur(4px)' }}
            exit={{ opacity: 0, backdropFilter: 'blur(0px)' }}
            className="absolute inset-0 bg-black/20 z-20 pointer-events-none"
          />
        )}
      </AnimatePresence>

      {/* CmdEdit Window (macOS Dark Theme) */}
      <AnimatePresence>
        {isCmdEditOpen && (
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
            className="relative z-30 w-[720px] h-[450px] bg-[#1E1E1E] rounded-xl border border-[#3A3A3C] shadow-2xl flex flex-col overflow-hidden text-white font-sans pointer-events-none select-none"
          >
            {/* Traffic Lights */}
            <div className="absolute top-4 left-4 flex gap-2 z-50">
              <div className="w-3 h-3 rounded-full bg-[#FF5F56] border border-black/20" />
              <div className="w-3 h-3 rounded-full bg-[#FFBD2E] border border-black/20" />
              <div className="w-3 h-3 rounded-full bg-[#27C93F] border border-black/20" />
            </div>

            <AnimatePresence mode="wait">
              {step.startsWith('editor') ? (
                <EditorView key="editor" step={step} />
              ) : (
                <HistoryView key="history" step={step} />
              )}
            </AnimatePresence>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

function Cursor({ isBlock = true }: { isBlock?: boolean }) {
  return (
    <motion.span
      animate={{ opacity: [1, 0] }}
      transition={{ repeat: Infinity, duration: 0.8 }}
      className={`inline-block h-4 bg-white/80 align-middle ${isBlock ? 'w-2.5 ml-[1px]' : 'w-[2px] -mr-[2px]'}`}
    />
  );
}

function Typewriter({ text, step, trigger }: { text: string, step: string, trigger: string }) {
  const [displayed, setDisplayed] = useState('');
  
  useEffect(() => {
    if (step === trigger) {
      let i = 0;
      setDisplayed('');
      const interval = setInterval(() => {
        setDisplayed(text.substring(0, i + 1));
        i++;
        if (i >= text.length) clearInterval(interval);
      }, 50);
      return () => clearInterval(interval);
    } else if (step !== 'terminal-idle') {
      setDisplayed(text);
    } else {
      setDisplayed('');
    }
  }, [step, text, trigger]);

  return <span>{displayed}</span>;
}

function EditorView({ step }: { step: string }) {
  const isSaving = step === 'editor-save';
  const isHistoryPress = step === 'editor-history-press';
  
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.98 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.98 }}
      transition={{ duration: 0.2 }}
      className="absolute inset-0 flex flex-col pt-12 px-4 pb-4 bg-[#232325]"
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-4 px-2">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-[#323234] flex items-center justify-center shadow-sm border border-white/10">
            <Command className="w-5 h-5 text-white" />
          </div>
          <span className="text-xl font-bold tracking-tight text-white">CmdEdit</span>
        </div>
        <div className="flex items-center gap-3">
          <motion.div 
            animate={{ 
              backgroundColor: isHistoryPress ? '#4A4A4C' : '#323234',
              scale: isHistoryPress ? 0.95 : 1
            }}
            className="px-3 py-1.5 rounded-lg text-sm font-medium text-white flex items-center gap-2 border border-white/5 shadow-sm"
          >
            History <kbd className="font-sans text-[12px] text-white/60 bg-black/30 px-2 py-0.5 rounded border border-white/10 shadow-inner flex items-center justify-center min-w-[32px] tracking-widest">⌘⇧H</kbd>
          </motion.div>
          <motion.div 
            animate={{ 
              backgroundColor: isSaving ? '#005BB5' : '#0A84FF',
              scale: isSaving ? 0.95 : 1
            }}
            className="px-3 py-1.5 rounded-lg text-sm font-medium text-white flex items-center gap-2 shadow-sm"
          >
            Save Back <kbd className="font-sans text-[12px] text-white/60 bg-black/30 px-2 py-0.5 rounded border border-white/10 shadow-inner flex items-center justify-center min-w-[32px] tracking-widest">⌘S</kbd>
          </motion.div>
        </div>
      </div>

      {/* Editor Area */}
      <div className="flex-1 rounded-xl border border-[#3A3A3C] flex flex-col overflow-hidden bg-[#1A1A1C] shadow-inner relative">
        <div className="h-10 bg-[#2D2D2F] border-b border-[#3A3A3C] flex items-center justify-between px-4">
          <div className="flex items-center gap-2 text-xs text-white/50 font-medium">
            <Code className="w-3.5 h-3.5" />
            Shell Buffer
          </div>
          <div className="text-xs text-white/40">Multiline supported</div>
        </div>
        <div className="p-4 font-mono text-[14px] text-white/90 leading-relaxed whitespace-pre outline-none flex-1 overflow-y-auto">
          {(step === 'editor-open' || step === 'editor-history-press') && (
            <span>curl -X POST \<Cursor isBlock={false} /></span>
          )}
          {step === 'editor-history-selected' && (
            <span>{`curl -X POST \\\n  https://api.example.com/v1/data \\\n  -H "Authorization: Bearer old_token" \\\n  -d '{"status": "active"}'`}<Cursor isBlock={false} /></span>
          )}
          {step === 'editor-select-word' && (
            <span>{`curl -X POST \\\n  https://api.example.com/v1/data \\\n  -H "Authorization: Bearer `}<span className="bg-[#0A84FF] text-white">old_token</span>{`" \\\n  -d '{"status": "active"}'`}</span>
          )}
          {step === 'editor-delete-word' && (
            <span>{`curl -X POST \\\n  https://api.example.com/v1/data \\\n  -H "Authorization: Bearer `}<Cursor isBlock={false} />{`" \\\n  -d '{"status": "active"}'`}</span>
          )}
          {step === 'editor-type-word' && (
            <span>{`curl -X POST \\\n  https://api.example.com/v1/data \\\n  -H "Authorization: Bearer `}<Typewriter text="new_token" step={step} trigger="editor-type-word" /><Cursor isBlock={false} />{`" \\\n  -d '{"status": "active"}'`}</span>
          )}
          {step === 'editor-save' && (
            <span>{`curl -X POST \\\n  https://api.example.com/v1/data \\\n  -H "Authorization: Bearer new_token" \\\n  -d '{"status": "active"}'`}</span>
          )}
        </div>
      </div>
    </motion.div>
  );
}

function HistoryView({ step }: { step: string }) {
  const isHovering = step === 'history-hover';
  
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.98 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.98 }}
      transition={{ duration: 0.2 }}
      className="absolute inset-0 flex flex-col pt-12 bg-[#232325]"
    >
      <div className="px-4 pb-4 border-b border-[#3A3A3C] flex items-center gap-4">
        <ChevronLeft className="w-5 h-5 text-white/70 cursor-pointer" />
        <div className="flex-1 relative">
          <Search className="w-4 h-4 text-white/40 absolute left-3 top-1/2 -translate-y-1/2" />
          <input 
            type="text" 
            disabled
            placeholder="Search commands..." 
            className="w-full bg-[#1A1A1C] border border-[#3A3A3C] rounded-lg pl-9 pr-4 py-2 text-sm text-white placeholder:text-white/40 focus:outline-none shadow-inner"
          />
        </div>
      </div>
      <div className="flex-1 overflow-y-auto p-2 flex flex-col gap-1 [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none]">
        <HistoryItem cmd="cd CmdEdit" lines="1 line" starred />
        <HistoryItem 
          cmd={`curl -X POST \\\n  https://api.example.com/v1/data \\\n  -H "Authorization: Bearer old_token" \\\n  -d '{"status": "active"}'`} 
          lines="4 lines" 
          active={isHovering}
        />
        <HistoryItem cmd="clear" lines="1 line" />
        <HistoryItem cmd="swift run" lines="1 line" />
        <HistoryItem cmd="cd macOS-App" lines="1 line" />
        <HistoryItem cmd="ls" lines="1 line" />
        <HistoryItem cmd="npm run dev" lines="1 line" />
      </div>
    </motion.div>
  );
}

function HistoryItem({ cmd, lines, starred, active }: { cmd: string; lines: string; starred?: boolean; active?: boolean }) {
  const singleLineCmd = cmd.replace(/\n\s*/g, ' ↵ ');
  const displayCmd = singleLineCmd.length > 80 ? singleLineCmd.substring(0, 80) + '...' : singleLineCmd;
  
  return (
    <div className={`flex items-center justify-between px-4 py-3 rounded-lg transition-colors ${
      active ? 'bg-[#0A84FF]' : 'hover:bg-white/5'
    }`}>
      <div className="flex items-center gap-4 min-w-0 flex-1">
        <Star className={`w-4 h-4 flex-shrink-0 ${starred ? 'text-[#FFD60A] fill-[#FFD60A]' : 'text-white/30'}`} />
        <div className="flex flex-col min-w-0 flex-1">
          <span className={`font-mono text-[13px] truncate ${active ? 'text-white' : 'text-white/90'}`}>
            {displayCmd}
          </span>
          <span className={`text-[11px] mt-0.5 ${active ? 'text-white/70' : 'text-white/40'}`}>{lines}</span>
        </div>
      </div>
      {active && (
        <div className="flex items-center gap-1 text-white/70 text-xs font-medium flex-shrink-0 ml-4">
          <CornerDownLeft className="w-3.5 h-3.5" />
          <span>Select</span>
        </div>
      )}
    </div>
  );
}
