import React from 'react';
import { ToastPosition } from 'react-hot-toast';
import { IconProp } from '@fortawesome/fontawesome-svg-core';

type Animation = {
  enter: string;
  exit: string;
}

export interface NotificationProps {
  title?: string;
  id?: number | string;
  description?: string; 
  type?: string; 
  duration?: number; // default: 3000
  icon?: IconProp; // default: check on type
  position?: ToastPosition; // default: top-right
  color?: string; // default: check on type
  closable?: boolean; // default: false (not semi-implementation)
  border?: boolean; // default: false (not semi-implementation)
  iconAnim: string; // default: false
  style?: React.CSSProperties;
  animation?: Animation;
}