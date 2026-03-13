import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Terminal, Command, X, Play, Save } from 'lucide-react';

interface HistoryItem {
  id: string;
  command: string;
  output?: string;
}

export default function App() {
  const [history, setHistory] = useState<HistoryItem[]>([
    {
      id: '1',
      command: 'echo "Welcome to the CmdEdit Web Demo!"',
      output: 'Welcome to the CmdEdit Web Demo!\n\nTry typing a long command below, then press Ctrl+E to open the CmdEdit overlay.\nYou can also click the "CmdEdit" button on the right.',
    }
  ]);
  const [currentInput, setCurrentInput] = useState('');
  const [isOverlayOpen, setIsOverlayOpen] = useState(false);
  const [overlayText, setOverlayText] = useState('');
  
  const terminalInputRef = useRef<HTMLInputElement>(null);
  const overlayTextareaRef = useRef<HTMLTextAreaElement>(null);
  const endOfTerminalRef = useRef<HTMLDivElement>(null);

  // Auto-scroll terminal to bottom
  useEffect(() => {
    endOfTerminalRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [history]);

  // Focus management
  useEffect(() => {
    if (isOverlayOpen) {
      // Small delay to allow animation to start and element to be focusable
      setTimeout(() => {
        if (overlayTextareaRef.current) {
          overlayTextareaRef.current.focus();
          // Move cursor to the end
          overlayTextareaRef.current.selectionStart = overlayTextareaRef.current.value.length;
          overlayTextareaRef.current.selectionEnd = overlayTextareaRef.current.value.length;
        }
      }, 50);
    } else {
      terminalInputRef.current?.focus();
    }
  }, [isOverlayOpen]);

  const executeCommand = (cmd: string) => {
    if (!cmd.trim()) return;
    
    const newItem: HistoryItem = {
      id: Date.now().toString(),
      command: cmd,
      output: `Executed: ${cmd}\n(This is a demo, so no real execution happened.)`
    };
    
    setHistory(prev => [...prev, newItem]);
    setCurrentInput('');
  };

  const handleTerminalKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'e' && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      openOverlay();
    } else if (e.key === 'Enter') {
      e.preventDefault();
      executeCommand(currentInput);
    }
  };

  const openOverlay = () => {
    setOverlayText(currentInput);
    setIsOverlayOpen(true);
  };

  const handleOverlayKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Escape') {
      e.preventDefault();
      setIsOverlayOpen(false);
    } else if (e.key === 's' && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      handleSaveBack();
    } else if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      handleRun();
    }
  };

  const handleSaveBack = () => {
    setCurrentInput(overlayText);
    setIsOverlayOpen(false);
  };

  const handleRun = () => {
    setCurrentInput(overlayText);
    setIsOverlayOpen(false);
    // Small delay to let the overlay close before executing
    setTimeout(() => executeCommand(overlayText), 100);
  };

  return (
    <div className="min-h-screen bg-zinc-950 text-zinc-300 font-mono flex flex-col items-center justify-center p-4 sm:p-8">
      
      {/* Fake Terminal Window */}
      <div className="w-full max-w-4xl h-[80vh] bg-zinc-900 rounded-xl shadow-2xl border border-zinc-800 flex flex-col overflow-hidden relative">
        {/* Terminal Header */}
        <div className="h-12 bg-zinc-900 border-b border-zinc-800 flex items-center px-4 select-none">
          <div className="flex space-x-2">
            <div className="w-3 h-3 rounded-full bg-red-500/80"></div>
            <div className="w-3 h-3 rounded-full bg-yellow-500/80"></div>
            <div className="w-3 h-3 rounded-full bg-green-500/80"></div>
          </div>
          <div className="mx-auto flex items-center text-zinc-500 text-sm font-sans">
            <Terminal className="w-4 h-4 mr-2" />
            user@macbook — -zsh — 80x24
          </div>
        </div>

        {/* Terminal Body */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4" onClick={() => terminalInputRef.current?.focus()}>
          {history.map((item) => (
            <div key={item.id} className="space-y-1">
              <div className="flex items-start">
                <span className="text-emerald-400 mr-2">➜</span>
                <span className="text-cyan-400 mr-2">~</span>
                <span className="text-zinc-100 whitespace-pre-wrap">{item.command}</span>
              </div>
              {item.output && (
                <div className="text-zinc-400 whitespace-pre-wrap mt-1">
                  {item.output}
                </div>
              )}
            </div>
          ))}
          
          {/* Current Input Line */}
          <div className="flex items-start group">
            <span className="text-emerald-400 mr-2 mt-0.5">➜</span>
            <span className="text-cyan-400 mr-2 mt-0.5">~</span>
            <div className="flex-1 relative flex items-center">
              <input
                ref={terminalInputRef}
                type="text"
                value={currentInput}
                onChange={(e) => setCurrentInput(e.target.value)}
                onKeyDown={handleTerminalKeyDown}
                className="w-full bg-transparent outline-none text-zinc-100 caret-zinc-100"
                spellCheck={false}
                autoComplete="off"
              />
              
              {/* Hint / Button to open overlay */}
              <button 
                onClick={openOverlay}
                className="absolute right-0 opacity-0 group-hover:opacity-100 transition-opacity flex items-center text-xs bg-zinc-800 hover:bg-zinc-700 text-zinc-300 px-2 py-1 rounded border border-zinc-700 font-sans"
              >
                <Command className="w-3 h-3 mr-1" />
                <span>CmdEdit (Ctrl+E)</span>
              </button>
            </div>
          </div>
          <div ref={endOfTerminalRef} />
        </div>
      </div>

      {/* CmdEdit Overlay */}
      <AnimatePresence>
        {isOverlayOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            {/* Backdrop */}
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsOverlayOpen(false)}
              className="absolute inset-0 bg-black/40 backdrop-blur-sm"
            />
            
            {/* Editor Window */}
            <motion.div 
              initial={{ opacity: 0, scale: 0.95, y: 10 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 10 }}
              transition={{ type: "spring", damping: 25, stiffness: 300 }}
              className="relative w-full max-w-2xl bg-zinc-900/80 backdrop-blur-2xl border border-white/10 rounded-2xl shadow-2xl overflow-hidden flex flex-col font-sans"
            >
              {/* Header */}
              <div className="px-5 py-4 border-b border-white/5 flex justify-between items-center bg-white/5">
                <div>
                  <h2 className="text-zinc-100 font-medium text-lg flex items-center">
                    <Command className="w-5 h-5 mr-2 text-zinc-400" />
                    CmdEdit
                  </h2>
                  <p className="text-zinc-500 text-xs mt-0.5">Edit Terminal Command</p>
                </div>
                <button 
                  onClick={() => setIsOverlayOpen(false)}
                  className="p-1.5 rounded-md hover:bg-white/10 text-zinc-400 hover:text-zinc-100 transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              {/* Editor Area */}
              <div className="p-5">
                <textarea
                  ref={overlayTextareaRef}
                  value={overlayText}
                  onChange={(e) => setOverlayText(e.target.value)}
                  onKeyDown={handleOverlayKeyDown}
                  className="w-full h-48 bg-transparent text-zinc-100 font-mono text-sm leading-relaxed outline-none resize-none selection:bg-blue-500/30"
                  spellCheck={false}
                  placeholder="Type your command here..."
                />
              </div>

              {/* Footer Actions */}
              <div className="px-5 py-4 border-t border-white/5 bg-black/20 flex items-center justify-between">
                <div className="text-xs text-zinc-500 flex items-center space-x-4">
                  <span className="flex items-center"><kbd className="font-sans bg-white/10 px-1.5 py-0.5 rounded mr-1.5 text-zinc-300">Esc</kbd> Cancel</span>
                </div>
                
                <div className="flex items-center space-x-3">
                  <button 
                    onClick={handleSaveBack}
                    className="flex items-center px-4 py-2 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-200 text-sm font-medium transition-colors border border-white/5"
                  >
                    <Save className="w-4 h-4 mr-2" />
                    Save Back
                    <kbd className="ml-2 font-sans text-xs text-zinc-500">⌘S</kbd>
                  </button>
                  
                  <button 
                    onClick={handleRun}
                    className="flex items-center px-4 py-2 rounded-lg bg-blue-600 hover:bg-blue-500 text-white text-sm font-medium transition-colors shadow-lg shadow-blue-900/20"
                  >
                    <Play className="w-4 h-4 mr-2" />
                    Run
                    <kbd className="ml-2 font-sans text-xs text-blue-200">⌘↵</kbd>
                  </button>
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
