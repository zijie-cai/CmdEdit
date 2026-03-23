import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { Terminal, Copy, Check, Command, ArrowRight } from 'lucide-react';
import { Demo } from './components/Demo';

export default function App() {
  const [isMobile, setIsMobile] = useState(false);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 1024);
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  const installCmd = `git clone --depth 1 https://github.com/zijie-cai/CmdEdit.git && bash CmdEdit/CmdEdit/Scripts/install.sh && source ~/.zshrc`;

  const handleCopy = () => {
    navigator.clipboard.writeText(installCmd);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  if (isMobile) {
    return (
      <div className="min-h-screen bg-[#F2F1EC] text-black flex flex-col items-center justify-center p-8 text-center border-[12px] border-black">
        <div className="font-mono text-sm font-bold uppercase tracking-widest border-2 border-black px-4 py-2 mb-8 bg-white shadow-[4px_4px_0px_rgba(0,0,0,1)]">
          CmdEdit
        </div>
        <h1 className="text-5xl font-bold tracking-tighter mb-6 uppercase leading-[0.9]">
          Edit Shell<br/>Commands
        </h1>
        <div className="font-mono text-lg bg-black text-white px-4 py-2 mb-12 flex items-center gap-2">
          like_real_text <span className="w-[2px] h-4 bg-[#00FF66] animate-pulse" />
        </div>
        <p className="text-black font-medium text-lg mb-12 max-w-[280px] border-l-4 border-black pl-4 text-left">
          CmdEdit is best experienced on a desktop environment.
        </p>
        <div className="px-6 py-4 bg-white border-2 border-black text-sm font-bold uppercase tracking-widest shadow-[4px_4px_0px_rgba(0,0,0,1)]">
          Open on desktop
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen w-full bg-[#F2F1EC] text-black overflow-hidden flex selection:bg-[#0044FF] selection:text-white">
      {/* Left Pane - Content */}
      <div className="w-[45%] h-full flex flex-col justify-between p-12 lg:p-16 xl:p-20 z-10 relative border-r-2 border-black bg-[#F2F1EC]">
        {/* Top Brand */}
        <header>
          <div className="font-mono text-xs font-bold uppercase tracking-widest border-2 border-black px-3 py-1.5 w-fit bg-white shadow-[2px_2px_0px_rgba(0,0,0,1)]">
            CmdEdit // v1.0
          </div>
        </header>

        {/* Main Copy */}
        <main className="flex flex-col justify-center flex-1 max-w-xl">
          {/* Unique Title Treatment */}
          <div className="flex flex-col gap-4 mb-10">
            <h1 className="text-[4.5rem] xl:text-[5.5rem] font-bold tracking-tighter leading-[0.9] uppercase text-black">
              Edit Shell<br/>Commands
            </h1>
            <div className="flex items-center gap-4">
              <div className="h-[3px] w-12 bg-black" />
              <span className="font-mono text-2xl xl:text-3xl bg-black text-white px-4 py-2 tracking-tight flex items-center gap-3 shadow-[4px_4px_0px_rgba(0,68,255,1)]">
                like_real_text <span className="w-[2px] h-6 bg-[#00FF66] animate-pulse" />
              </span>
            </div>
          </div>
          
          {/* Supporting Text - No gray, structural emphasis */}
          <div className="border-l-4 border-black pl-6 mb-12 py-1">
            <p className="text-lg font-medium leading-relaxed max-w-md text-black">
              A native macOS command editor overlay for zsh. Press <kbd className="font-mono bg-white border-2 border-black px-1.5 py-0.5 rounded-sm text-sm font-bold shadow-[2px_2px_0px_rgba(0,0,0,1)] mx-1">Ctrl+E</kbd> to open. Search history, access starred commands, and Save Back to prompt.
            </p>
          </div>

          {/* CTA / Install Area */}
          <div className="flex flex-col gap-3">
            <div className="font-mono text-[10px] font-bold uppercase tracking-widest text-black/60">
              Install via Terminal
            </div>
            <div className="flex items-center bg-white border-2 border-black p-1.5 shadow-[4px_4px_0px_rgba(0,0,0,1)] hover:shadow-[6px_6px_0px_rgba(0,0,0,1)] transition-shadow duration-300">
              <div className="flex items-center justify-center w-12 h-12 shrink-0 bg-[#F2F1EC] border-2 border-black">
                <Terminal className="w-5 h-5 text-black" />
              </div>
              <div className="flex-1 overflow-hidden px-4">
                <div className="font-mono text-xs font-medium whitespace-nowrap overflow-x-auto [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none]">
                  {installCmd}
                </div>
              </div>
              <button 
                onClick={handleCopy}
                className="shrink-0 ml-2 w-[120px] py-3 bg-black text-white hover:bg-[#0044FF] text-sm font-bold uppercase tracking-wider transition-colors flex items-center justify-center gap-2"
              >
                {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
                {copied ? 'Copied' : 'Copy'}
              </button>
            </div>
          </div>
        </main>

        {/* Footer */}
        <footer className="flex items-center justify-between w-full">
          <a 
            href="https://github.com/zijie-cai/CmdEdit" 
            target="_blank" 
            rel="noreferrer"
            className="text-xs font-bold uppercase tracking-widest text-black hover:text-[#0044FF] transition-colors flex items-center gap-2 group"
          >
            View Source on GitHub
            <ArrowRight className="w-4 h-4 opacity-0 -translate-x-2 group-hover:opacity-100 group-hover:translate-x-0 transition-all" />
          </a>
          <div className="text-xs text-black/40 font-medium">
            Built by{' '}
            <a 
              href="https://zijiecai.com" 
              target="_blank" 
              rel="noreferrer"
              className="text-black/70 hover:text-[#0044FF] transition-colors underline decoration-black/30 hover:decoration-[#0044FF] underline-offset-4"
            >
              Zijie Cai
            </a>
          </div>
        </footer>
      </div>

      {/* Right Pane - Demo */}
      <div className="w-[55%] h-full relative bg-[#EAE8E3] overflow-hidden flex items-center justify-center">
        <div className="w-full h-full relative">
          <Demo />
        </div>
      </div>
    </div>
  );
}
