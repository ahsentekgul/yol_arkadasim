
import { ButtonHTMLAttributes, ReactNode } from 'react';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
  size?: 'small' | 'medium' | 'large' | 'xl' | 'custom';
  children: ReactNode;
  isLoading?: boolean;
  fullWidth?: boolean;
}

export default function Button({
  variant = 'primary',
  size = 'medium',
  children,
  isLoading = false,
  fullWidth = false,
  className = '',
  disabled,
  ...props
}: ButtonProps) {
  const baseClasses = 'font-semibold rounded-xl transition-all duration-200 focus:outline-none focus:ring-4 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed';
  
  const variantClasses = {
    primary: 'bg-blue-600 hover:bg-blue-700 text-white focus:ring-blue-500',
    secondary: 'bg-gray-200 hover:bg-gray-300 text-gray-900 focus:ring-gray-500',
    danger: 'bg-red-600 hover:bg-red-700 text-white focus:ring-red-500',
    ghost: 'bg-transparent hover:bg-gray-100 text-gray-700 focus:ring-gray-500'
  };

  const sizeClasses = {
    small: 'px-4 py-2 text-sm min-h-[40px]',
    medium: 'px-6 py-3 text-base min-h-[48px]',
    large: 'px-8 py-4 text-lg min-h-[56px]',
    xl: 'px-10 py-5 text-xl min-h-[64px]',
    custom: '' // No default sizing for custom buttons
  };

  const widthClass = fullWidth ? 'w-full' : '';

  // Only apply default variant classes if not using custom size
  const appliedVariantClasses = size === 'custom' ? '' : variantClasses[variant];

  return (
    <button
      className={`${baseClasses} ${appliedVariantClasses} ${sizeClasses[size]} ${widthClass} ${className}`}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? (
        <div className="flex items-center justify-center">
          <i className="ri-loader-4-line animate-spin mr-2" aria-hidden="true"></i>
          Loading...
        </div>
      ) : (
        children
      )}
    </button>
  );
}
